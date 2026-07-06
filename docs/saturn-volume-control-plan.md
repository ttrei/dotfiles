# Saturn Volume Control — Implementation Plan

A minimal LAN volume remote for the HTPC **saturn**. One HTTP service on saturn
(defined declaratively in NixOS) is the **single source of truth** for volume
changes. Three things drive it:

1. A single static **web page** on a phone browser (presets + granular + mute).
2. The existing **i3 keybinds**, rewritten to be thin HTTP clients of the same
   service instead of touching the mixer directly.
3. (Internally) the service also raises an **on-screen volume overlay (OSD)** on
   every change, so any volume change — from the phone, the keyboard media keys,
   whatever — shows a large volume bar on the TV that fades after ~1000ms, even
   over fullscreen video/Kodi.

Backend: **PulseAudio via `pactl`** on the default sink. No native Android app.
No auth. Hardcoded saturn IP. Absolute + relative controls. No volume cap.
Latency-optimised.

Presets: **Low = 25%**, **Mid = 50%**, **High = 75%**.

---

## 0. Context discovered from the existing config

These facts drove every decision below (so the plan matches how saturn already
works rather than inventing a parallel mechanism):

| Fact | Source | Consequence |
| --- | --- | --- |
| Audio stack is **PulseAudio**, PipeWire disabled | `nix/nixos/saturn.nix` (`services.pulseaudio.enable = true`) | Use `pactl` on the default sink (not `wpctl`, not ALSA). |
| Current `i3-volume-control` drives **ALSA `amixer Master`** with a 2% step and a `< 39` cap | `i3/bin/i3-volume-control` | This script is being **rewritten** to call the new HTTP API. Old ALSA/cap logic is dropped. |
| But i3blocks **displays** volume via a **`[volume-pulseaudio]`** block (`signal=10`) | `i3/i3blocks/config-htpc` | The display side already reads **PulseAudio**, while the old script wrote **ALSA** — a latent inconsistency. Standardising everything on `pactl` **fixes** this. |
| i3blocks refreshed via `pkill -RTMIN+10 i3blocks` after change | `i3-volume-control`, `config-htpc` (`signal=10`) | The service does this centrally after every change, so the bar tracks all clients. |
| User `reinis`, **uid 1000**, in `audio` group | `nix/nixos/users/reinis.nix` | Service + OSD run in reinis' session. |
| **Autologin is on** (lightdm → i3, `autoLogin.user = "reinis"`), default session `none+i3` | `nix/nixos/x11.nix` | A uid-1000 X session + PulseAudio is (almost) always present; `/run/user/1000` and the X display exist. Enables both `pactl` and the on-screen OSD. |
| **Kodi runs as a desktop-manager session** (`services.xserver.desktopManager.kodi`) alongside i3; i3 has floating rules for Vlc/MPlayer but **none for Kodi** (Kodi self-manages fullscreen) | `nix/nixos/saturn.nix`, `i3/config/config` | The OSD must be **genuinely always-on-top** to draw over fullscreen Kodi — a plain notification toast won't cut it. This is the riskiest part (see §OSD). |
| saturn IP = **`192.168.8.205`**, LAN = `192.168.8.*` | `nix/nixos/hosts` | Hardcode this in the page; firewall-scope to the subnet. |
| Firewall **on**, ports via `networking.firewall.allowedTCPPorts` (list already exists) | `nix/nixos/saturn.nix` | Add one port (subnet-scoped). |
| NixOS **26.05**; formatting enforced by pre-commit: `nixfmt-rfc-style`, `ruff`, `ruff-format` | `flake.nix`, `.pre-commit` hooks | Nix must be nixfmt-clean; **avoid embedding Python in Nix strings**. Favour a checked-in `.py` file (ruff-linted) or shell. |
| Config is plain NixOS modules; `modules/nixos` is empty scaffolding | repo layout | Ship as a normal module imported by `saturn.nix`. |

### Why `pactl` (PulseAudio) and not `amixer` (ALSA)
Switching the backend to `pactl` for **everything**:
- The old setup is **already inconsistent** — the script wrote ALSA `Master`
  while i3blocks reads PulseAudio. Routing all changes through `pactl` makes the
  bar, the OSD, and the API agree. This is a bug fix, not just a preference.
- `pactl` targets **`@DEFAULT_AUDIO_SINK@`** — the sink that actually reaches the
  TV/HDMI output — rather than assuming an ALSA `Master` control exists on that
  output.
- With the **40% cap removed**, the ALSA-specific guard logic disappears, so
  there's nothing ALSA was buying us anyway.
- Clean percentage get/set and mute query.

Cost: `pactl` needs the user's **PulseAudio session** (ALSA was system-level).
Autologin guarantees the uid-1000 session is up, and the service already runs as
`reinis` with `XDG_RUNTIME_DIR=/run/user/1000`, so this is covered.

---

## 1. Architecture

```
┌─────────────┐  HTTP (LAN, keep-alive)  ┌───────────────────────────────────┐
│  Phone      │ ───────────────────────▶ │ saturn 192.168.8.205:PORT          │
│  browser    │                          │  volume HTTP service (as reinis)   │
│  (1 static  │ ◀─────────────────────── │   → pactl set-sink-volume ...      │
│   page)     │  JSON {"volume":N,...}    │   → pactl get (re-read) → JSON     │
└─────────────┘                          │   → trigger OSD (xob) on the TV    │
                                         │   → pkill -RTMIN+10 i3blocks       │
┌─────────────┐  HTTP (localhost)        │                                    │
│ i3 keybinds │ ───────────────────────▶ │  (same endpoints)                  │
│ XF86Audio*  │                          │                                    │
└─────────────┘                          └───────────────────────────────────┘
```

Every volume change — phone or keyboard — funnels through the **one** service, so
the re-read value, the OSD, and the i3blocks refresh all happen in exactly one
place regardless of trigger.

- **Server**: a NixOS `systemd.services.*` unit, running as **user `reinis`**
  (uid 1000, `audio` group) with `XDG_RUNTIME_DIR=/run/user/1000` and
  `DISPLAY=:0`, so it can reach both PulseAudio and the X display. Endpoints wrap
  `pactl`; after each change it pushes the new value to the **OSD** and refreshes
  i3blocks.
- **Client (phone)**: one `index.html` (inline CSS + JS, no build step, no
  framework) served by that same service at `/`. Open once, "Add to Home Screen".
- **Client (keyboard)**: `i3-volume-control` rewritten to `curl` the API (§7b).
- **Transport**: plain HTTP on the trusted LAN. HTTP keep-alive to kill per-tap
  connection setup latency.

Single service serves **both** the API and the page → no CORS, no second port,
nothing else to run.

---

## 2. HTTP API contract

Base URL: `http://192.168.8.205:PORT` (PORT decided in §6, default **8899**).

All mutating actions are **POST** and **return the resulting real volume** in
the body (as requested), so the page always shows ground truth, never a guess.

| Method | Path | Action | Body (response) |
| --- | --- | --- | --- |
| `GET`  | `/`            | Serve the web page (HTML) | — |
| `GET`  | `/volume`      | Read current volume (initial page load) | `{"volume": 50, "muted": false}` |
| `POST` | `/volume/set?v=50` | Absolute set to 50% (clamped to `[0, 100]`) | `{"volume": 50, "muted": false}` |
| `POST` | `/volume/up`   | Relative +step | `{"volume": 52, ...}` |
| `POST` | `/volume/down` | Relative −step | `{"volume": 48, ...}` |
| `POST` | `/volume/mute` | Toggle mute | `{"volume": 48, "muted": true}` |

Design notes:
- **Absolute** = presets (Low/Mid/High). **Relative** = the +/− granular buttons.
- Response is **always the freshly re-read** value (run the mutate via `pactl`,
  then `pactl` get, return that). Guarantees the number on screen is real.
- **No `max`** — the cap is removed; range is a plain `[0, 100]`. (`pactl` can
  exceed 100% via software boost; the service **clamps to 100** on `set`/`up` so
  the UI stays sane. If boost above 100% is ever wanted, that clamp is the one
  knob to change.)
- Query params (`?v=`) over JSON bodies for mutate calls — trivial to emit from
  `fetch`, nothing to parse server-side.
- **Side effects of every mutate**, done server-side (so all clients benefit):
  (1) push new % to the **OSD**, (2) `pkill -RTMIN+10 i3blocks`, (3) re-read,
  (4) respond. `GET /volume` has **no** side effects (no OSD) — it's just a read
  for page init.
- Return `400` on a non-numeric / out-of-range `v`. No other error surface
  needed for a home LAN.
- Add a permissive `Access-Control-Allow-Origin: *` header (one line) as free
  insurance for `file://`/cross-origin testing. Not strictly needed (same-origin).

### Preset mapping
- **Low** → `set 25`
- **Mid** → `set 50`
- **High** → `set 75`
- Granular **+ / −** → `up` / `down` (**1% step**, for fine trim; the slider
  handles coarse jumps. Configurable via the `step` option).

---

## 3. Server implementation

A ~90-line `volume_server.py` using `http.server.ThreadingHTTPServer` +
`BaseHTTPRequestHandler`, calling `pactl` via `subprocess`. Checked into the
repo as a real `.py` (so **ruff/ruff-format apply** — consistent with the
existing i3pyblocks Python), referenced from Nix via its path.

Pros: robust request parsing, easy JSON, **native HTTP keep-alive**
(`protocol_version = "HTTP/1.1"`) → best latency story; trivially readable; easy
to also shell out to the OSD + i3blocks refresh in one place.
Cons: pulls `python3` into the closure (already present on saturn anyway via
i3pyblocks/i3ipc, so effectively free).

> the service **must** run in reinis' audio **and** X context
> (for `pactl` and the OSD). Because autologin guarantees a uid-1000 X session,
> running the unit as user `reinis` with `XDG_RUNTIME_DIR=/run/user/1000` and
> `DISPLAY=:0` is the clean path (see §4).

---

## 4. NixOS service module

New file: `nix/nixos/services/volume-control.nix`, imported from
`nix/nixos/saturn.nix`'s `imports = [ ... ]`.

Responsibilities:
1. **Package the server.** wrap the checked-in `.py` with
   `pkgs.writers.writePython3Bin` (or `writeShellApplication`), with
   `runtimeInputs = [ pkgs.pulseaudio pkgs.xob pkgs.procps ]` so `pactl`,
   `xob`, and `pkill` are on PATH. (Reference the standalone `.py` file so ruff
   lints it, not a Nix here-string.)
2. **Define the systemd unit** (`systemd.services.saturn-volume`):
   - `wantedBy = [ "multi-user.target" ]`.
   - `serviceConfig.User = "reinis"` (uid 1000; in `audio` group).
   - `Environment = [ "XDG_RUNTIME_DIR=/run/user/1000" "DISPLAY=:0" ]` so it
     reaches the user's **PulseAudio** session (for `pactl`) **and** the **X
     display** (for the OSD + i3blocks signal). Both needed now.
   - Ordering: it depends on the user session being up. Options: `After` the
     display-manager, or accept the `Restart` loop below papers over early-boot
     races. Simplest robust approach may actually be a **systemd *user* service**
     for reinis (`systemd.user.services` + `enable-linger`) so it inherits the
     session environment naturally — see §10 risks.
   - `Restart = "on-failure"`, `RestartSec = 2`.
   - Hardening that does **not** break audio **or X**: `NoNewPrivileges`. Be
     conservative with `ProtectSystem`/`PrivateTmp` here — the OSD needs the X
     socket (`/tmp/.X11-unix`) and `pactl` needs `/run/user/1000`. Over-tight
     sandboxing will silently break the OSD. Start permissive; it's a LAN toy.
   - Bind port from an option; default 8899.
3. **Open the firewall, scoped to the LAN.** Prefer subnet-scoping over a blanket
   open:
   - Simplest: append the port to the existing
     `networking.firewall.allowedTCPPorts` list in `saturn.nix`.
   - Tighter (recommended): a `networking.firewall.extraCommands` / nftables rule
     allowing the port **only from `192.168.8.0/24`**, so the endpoint isn't
     reachable over the Mullvad `wg-mullvad` interface. With **no auth**,
     subnet-scoping is the main safety measure — worth doing.
4. **Ensure `xob` is available and running** for the OSD (see §5 for the full
   OSD design). Either the service spawns/manages a long-lived `xob` process it
   pipes to, or `xob` is started once in the i3/X session and the service writes
   to a shared FIFO. The module installs `pkgs.xob` and drops an `xob` style
   config (colours/size/`-t 1000` timeout).
5. **Rewrite `i3-volume-control`** to call the API (§7b) and install it on PATH
   (replacing the old amixer script), so the media keys and the phone share one
   backend.
6. **Expose a small options interface** (keeps it declarative):
   ```
   services.saturnVolume = {
     enable = true;
     port   = 8899;
     step   = 1;      # relative step % (fine trim; slider does coarse moves)
     presets = { low = 25; mid = 50; high = 75; };
     osd = {
       enable = true;
       timeoutMs = 1000;   # how long the bar stays before fading
     };
   };
   ```
### Volume operations (server internals, via `pactl`)
- **read %**: `pactl get-sink-volume @DEFAULT_AUDIO_SINK@` → parse the first
  `NN%`. (Or use `pactl --format=json` on new enough Pulse for robust parsing.)
- **muted?**: `pactl get-sink-mute @DEFAULT_AUDIO_SINK@` → `yes`/`no`.
- **set N**: clamp `N` to `[0, 100]`, then
  `pactl set-sink-volume @DEFAULT_AUDIO_SINK@ N%`.
- **up**: read → `min(cur + step, 100)` → set. (Explicit clamp so we never
  software-boost past 100% unless intended.)
- **down**: read → `max(cur - step, 0)` → set (explicit floor).
- **mute**: `pactl set-sink-mute @DEFAULT_AUDIO_SINK@ toggle`.
- **After any mutate** (not on plain reads): push new % to the **OSD**
  (§5); if `refreshI3Blocks`, `pkill -RTMIN+10 i3blocks || true`.
- Then **re-read** and return `{"volume", "muted"}`.

> Edge case: `pactl` needs the user's PulseAudio session. Autologin keeps it up.
> If the service starts before the session (early boot), the `Restart=on-failure`
> loop — or running as a user service — recovers once the session exists.

---

## 5. On-screen volume overlay (OSD) — the visual indication

**Requirement:** a large volume bar appears on the TV on *every* volume change,
visible even over a playing video/Kodi, and disappears quickly (~1000ms).

### Why this is triggered server-side, once
Because **all** changes now flow through the one HTTP service (phone *and* media
keys), the OSD is a property of the **change event**, not of any client. The
service fires the OSD centrally after each mutate. This is the key design win:
the phone doesn't (and can't) draw on the TV; the keyboard path shouldn't
duplicate OSD logic. One place, every trigger.

### Tool: `xob` (X Overlay Bar) — recommended
`xob` is a purpose-built, minimal X11 overlay bar: you pipe a number `0..100`
into it on stdin and it renders a bar that fades after a timeout. Fit here:
- **Always-on-top** X window → can draw over fullscreen content.
- **`-t 1000`** → the ~1000ms auto-hide requirement, directly.
- Styleable (size, colours, orientation) via a small config → "large bar at the
  top of the screen".
- Trivial to drive: `echo 52 > $XOB_FIFO`. Mute can be shown via xob's
  alternate/overflow colour or a separate signal.

**Wiring (recommended: long-lived xob + FIFO):**
1. Create a FIFO (e.g. `/run/user/1000/xob.fifo`).
2. Start `xob` **once in the X/i3 session**, reading that FIFO:
   `tail -f $FIFO | xob -t 1000 -s saturn` (a style name from `styles.cfg`).
   Placed in the i3 `exec` startup (or a small user service).
3. The volume service, after each change, writes the new percentage to the FIFO.
   Because the service runs as reinis with `DISPLAY=:0`, it can alternatively
   spawn a short-lived `xob` per event — but a persistent reader avoids
   window-create latency each time (**better for the snappy feel**).

### The hard part (flagged honestly): drawing over **fullscreen Kodi**
This is the **single riskiest** piece of the whole project. Notes:
- Kodi here runs under **X11/i3** (not GBM/standalone), and i3 has **no special
  fullscreen rule for Kodi** — Kodi self-manages. An always-on-top override
  window like `xob` **usually** paints above X11 fullscreen, but exclusive
  fullscreen GL apps can occasionally win the top layer depending on compositor
  state and Kodi's display mode.
- **Mitigations if xob is hidden behind Kodi:**
  - Run i3 with a compositor (`picom`) — override-redirect OSDs composite
    reliably above fullscreen when a compositor is present. (Adds `picom` to the
    session; low cost, big reliability boost for overlays.)
  - Ensure xob's window is override-redirect / dock-type and mapped
    above-others; xob does this by default.
  - As a fallback, use **Kodi's own** volume OSD for the Kodi case (Kodi shows a
    volume bar natively when volume changes *through Kodi*) — but that only
    covers changes made inside Kodi, not the phone, so it's a partial fallback
    only. Prefer making xob work.
- **This must be tested on the real box early** (see §9 step ordering). If xob
  refuses to sit above Kodi even with picom, alternatives are `volnoti`
  (dbus OSD) or a tiny always-on-top GTK/`yad` window — but try xob+picom first.

### Alternatives considered
- **dunst / notify-send: rejected.** It's a corner *toast*, not a big bar, and
  won't reliably float above fullscreen video. (dunst appears in the repo but
  only for the *Debian* HTPC, and isn't installed on NixOS saturn anyway.)
- **volnoti:** viable icon+bar OSD; fallback if xob styling/fullscreen disappoints.

### OSD options surface
`services.saturnVolume.osd = { enable = true; timeoutMs = 1000; }` — the timeout
feeds xob's `-t`; disabling skips the FIFO write (useful for headless testing).

---

## 6. Port & networking

- **Port**: `8899` (unused by the existing list: 4533/8080/8989/7878/9117/6767/
  9091/56322/4533). Confirm no clash before finalising.
- **Firewall**: subnet-scoped to `192.168.8.0/24` (see §4.3). At minimum, add
  `8899` to `allowedTCPPorts`.
- **Address binding**: bind the HTTP server to `0.0.0.0` (or specifically
  `192.168.8.205`). Binding to the LAN IP only is marginally safer than
  `0.0.0.0` given the VPN interface exists.
- **Hostname vs IP on the client**: requirement is hardcoded IP →
  `http://192.168.8.205:8899`. (Aside: phones don't resolve the `extraHosts`
  `saturn` entry, so IP is the right call anyway.)

---

## 7. Web page (`index.html`)

One self-contained file served at `/`. No framework, no build. Vanilla HTML +
inline CSS + a small `<script>`.

### Layout (top → bottom, thumb-friendly)

```
┌───────────────────────────────────────┐
│                                        │
│     50 %                    [ 🔊 ]      │  ← big readout  +  mute button (right)
│                                        │
├───────────────────────────────────────┤
│  ▁▁▁▁▁▁▁▁▁▁●▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁     │  ← horizontal slider, full width, 0–100
├───────────────────────────────────────┤
│    [   Low   ] [   Mid   ] [   High  ]  │  ← presets (absolute set 25/50/75)
├───────────────────────────────────────┤
│        [     −     ]  [     +     ]     │  ← granular ±1%, large
└───────────────────────────────────────┘
```

1. **Header row**: big current-volume **readout** (e.g. `50%`) on the left, a
   **mute button** on the right, next to it.
2. **Slider**: full-width **horizontal** `range` input, `0..100`, directly under
   the readout so the number and the bar are visually coupled.
3. **Presets row**: `Low` `Mid` `High` → POST `/volume/set?v=25|50|75`.
4. **Granular row**: large `−` / `+` → POST `/volume/down` / `/up` (**1% step**).

### Mute is orthogonal to the volume number
Per requirement: **while muted, the volume level stays visible** so you can see
how loud it'll be when unmuted.
- The **readout always shows the volume %** (e.g. `50%`), muted or not.
- The **mute state is a separate visual**: the mute button toggles its
  icon/label (`🔊` ↔ `🔇`), and when muted the readout + slider are rendered
  **dimmed** (e.g. reduced opacity) with a small `🔇` marker — so an unattended
  glance reads "50%, but silenced".
- **Muting never moves the slider thumb or changes the number.** `mute` =
  `pactl ... toggle`; the response's `volume` is unchanged, only `muted` flips.

### Slider behaviour — throttled-live, with drag ownership
A slider streams values, which conflicts with (a) latency and (b) our
"always show the server's real value" rule. Resolution:

- **Throttled-live send.** On the `input` event (fires continuously while
  dragging), send `POST /volume/set?v=<thumb>` **at most every ~60ms**
  (throttle), so volume audibly tracks the thumb without flooding the network.
  **Always send a final** `set` on `change` (release) so the end position is
  exact even if the last throttle tick was skipped.
- **Drag ownership (the key rule).** While the user is **actively dragging**,
  the **slider owns the thumb position** — do **not** write server responses back
  into the thumb. Otherwise a stale in-flight response ("48") yanks the thumb
  backward while you've already moved on (classic slider jitter). Only sync the
  thumb **from** the server when **not** dragging (initial load, preset/±
  presses, idle).
- **Coalesce in-flight.** Keep at most **one** `set` request in flight; if the
  throttle fires while one is pending, **replace** the pending value rather than
  queueing. Prevents backlog on a Wi-Fi hiccup.
- **Readout during drag** follows the thumb **optimistically** (updates from the
  slider immediately). This is the one deliberate exception to "never guess" —
  the alternative (readout lagging the thumb) feels broken. The **TV OSD still
  shows ground truth** regardless, and on release the authoritative value lands.

### How the three controls stay coherent
| Control | Sends | Updates readout | Updates slider thumb |
| --- | --- | --- | --- |
| **Slider drag** | `set` (throttled + final) | yes, optimistic from thumb | owns it (drag); synced from server only when idle |
| **Preset button** | `set 25\|50\|75` | from response (authoritative) | **yes**, from response |
| **± button** | `up` / `down` | from response | **yes**, from response (thumb visibly nudges) |
| **Mute button** | `mute` | unchanged (dim toggles) | unchanged |
| **`GET /volume`** (load / idle refresh) | — | from response | from response |

So: **± buttons and presets both move the thumb** (they update from the
authoritative response); only an *active drag* suppresses server→thumb writes.

### Behaviour (general)
- On load: `GET /volume` → render volume %, slider thumb, muted state.
- Each **button** tap: `fetch(..., {method:'POST', keepalive:true})` → update
  readout **and** thumb from the returned JSON (ground truth).
- Range is a plain `0..100`; disable `+`/`High` at 100, `−`/`Low` at 0.
- Minimal styling: large hit targets (min ~64px), high contrast, **dark theme**
  (HTPC-in-a-dark-room friendly), `viewport` meta, `user-scalable=no` to avoid
  accidental double-tap zoom. Enlarge the slider thumb/track for touch.
- The phone page needs **no volume-bar animation of its own** — the TV **OSD**
  is the shared visual feedback; the page just shows number + thumb.
- PWA niceties (optional, tiny): `apple-mobile-web-app-capable`, a
  `theme-color`, maybe a 1-file `manifest.json` so "Add to Home Screen" gives a
  clean icon + standalone chrome. Not required for function.

### Latency techniques (the stated priority)
- **HTTP keep-alive** end to end (server `HTTP/1.1` + browser reuses the socket)
  → removes TCP/TLS setup per tap. Biggest single win.
- **No TLS** (plain HTTP on LAN) → no handshake at all.
- **Tiny payloads** (a few-byte JSON) → negligible transfer time.
- **Fire on `pointerdown`**, not `click`, for the +/− buttons → shaves the
  ~50–300ms browsers add waiting to disambiguate taps/double-taps. Guard against
  double-firing.
- **`touch-action: manipulation`** on buttons → disables double-tap-zoom delay.
- **Serialise requests**: keep at most **one in-flight request** (per the slider
  coalescing in §7 above), so rapid taps / drag ticks can't queue a backlog;
  replace a pending value rather than appending.
- Expect **Wi-Fi radio wake** to dominate after idle (10–200ms) — unavoidable
  from the page; keep-alive + a periodic tiny `GET /volume` heartbeat (say every
  10–20s while the page is open) can keep the socket/radio warm if it proves
  annoying. Add only if needed.

---

## 7b. Rewriting `i3-volume-control` (the keyboard path)

The existing `i3/bin/i3-volume-control` (amixer + 2% + `< 39` cap +
`pkill i3blocks`) is **replaced** by a thin client of the API so the media keys
and the phone share one backend and both raise the OSD.

### New script (shape)
```bash
#!/usr/bin/env bash
# i3-volume-control — thin client for the saturn volume HTTP API
BASE="http://127.0.0.1:8899"   # localhost: no firewall dependency
case "$1" in
  up)   curl -fsS -X POST "$BASE/volume/up"   >/dev/null ;;
  down) curl -fsS -X POST "$BASE/volume/down" >/dev/null ;;
  mute) curl -fsS -X POST "$BASE/volume/mute" >/dev/null ;;
  set)  curl -fsS -X POST "$BASE/volume/set?v=${2:?}" >/dev/null ;;
  *)    echo "Usage: $0 [up|down|mute|set N]" >&2; exit 1 ;;
esac
```

Notes:
- Targets **`127.0.0.1`** so the keyboard path never depends on the firewall
  rule and has the lowest possible latency (loopback).
- **No more OSD or i3blocks logic in the script** — the service does both
  centrally now. This is the whole point of routing keys through the API.
- The old `XF86Mail → set 30` binding stays valid (now hits the API). Consider
  remapping it to a preset (e.g. `set 50`) for consistency — optional.
- i3 keybinds in `i3/config/config` are unchanged (same CLI surface:
  `up|down|mute|set N`), so no i3 config churn.
- **Latency caveat:** each key press now spawns `curl` (process start ~5–15ms) +
  a loopback round-trip. For media keys this is imperceptible. If ever it isn't,
  a persistent keep-alive client could replace `curl`, but that's almost
  certainly unnecessary.

### Trade-off acknowledged
This makes the keyboard **depend on the HTTP service running**. If the service
is down, the media keys do nothing (vs. the old script which was self-contained).
Given the service is a reboot-safe systemd unit with `Restart=on-failure`, this
is an acceptable coupling — and it's the only way to get the shared OSD +
single-source-of-truth behaviour requested. (If this coupling is undesirable,
the alternative is to duplicate volume+OSD logic in the script, which defeats
the purpose.)

---

## 8. File/repo layout (proposed)

```
i3/bin/
  i3-volume-control               # REWRITTEN: thin curl client of the API
nix/nixos/
  saturn.nix                      # + import ./services/volume-control.nix
  services/
    volume-control.nix            # NixOS module: options, systemd unit, firewall,
                                  #   xob/OSD wiring, installs rewritten script
    volume/
      volume_server.py            # Option B server (ruff-linted, uses pactl)
      index.html                  # the web page (served at /)
      xob-styles.cfg              # xob style (size/colour/top placement)
```

- `index.html` / `xob-styles.cfg` referenced by path from the module (real
  files, not Nix here-strings) → readable, diff-friendly, and Python gets ruff.
- The rewritten `i3-volume-control` lives where it already does (`i3/bin/`), and
  is put on PATH via the module (replacing the amixer version). Confirm how it's
  currently installed on NixOS — `stage.sh` symlinks it for the Debian flow, but
  on saturn it must be a package/`environment.systemPackages` entry or a
  `writeShellApplication`. **Open item:** verify the current install path on
  NixOS so the rewrite actually lands on PATH.
- Everything lives under the dotfiles repo so it deploys with the normal NixOS
  rebuild flow — no out-of-band artifacts.

---

## 9. Build / deploy / test steps

1. **Add files** per §8; rewrite `i3-volume-control`; wire the import into
   `saturn.nix`.
2. **Format**: run the repo's pre-commit (`nixfmt-rfc-style`, `ruff`,
   `ruff-format`) so the commit passes hooks.
3. **Rebuild saturn**: standard flow (e.g. `nixos-rebuild switch --flake` for
   `saturn`, or the repo's existing deploy command).
4. **Smoke-test the API on saturn** (SSH):
   - `curl http://localhost:8899/volume` → sane JSON `{"volume":N,"muted":…}`.
   - `curl -X POST 'http://localhost:8899/volume/set?v=50'` → audibly 50%, JSON
     shows 50, i3blocks bar updates, **OSD bar appears on the TV and fades**.
   - `curl -X POST http://localhost:8899/volume/up` / `.../down` → ±1%.
   - `curl -X POST 'http://localhost:8899/volume/set?v=150'` → clamped to 100.
   - `curl -X POST http://localhost:8899/volume/mute` → toggles + OSD reflects it.
   - `systemctl status saturn-volume`, `journalctl -u saturn-volume` clean.
5. **Test the OSD over Kodi early** (this is the risky bit — don't leave it last):
   - Start Kodi, play a fullscreen video, fire a `set`/`up` via curl, confirm the
     xob bar draws **over** the video and fades in ~1000ms. If hidden, add
     `picom` to the session and retry (see §5). Resolve before polishing UI.
6. **Test the keyboard path**: press the media keys → volume changes, OSD shows,
   i3blocks updates. Confirm the rewritten script is the one on PATH
   (`command -v i3-volume-control`).
7. **From the phone (same LAN)**: browse to `http://192.168.8.205:8899`,
   verify buttons move real volume, readout tracks it, and the TV OSD fires.
   Measure tap→sound feel; apply §7 latency techniques if sluggish.
8. **Add to Home Screen** for the app-like launcher.
9. **Reboot saturn** once and re-test end-to-end to confirm the unit (and xob)
   come up with the autologin session (validates the session-dependency
   assumptions for both `pactl` and the OSD).

> Tip: the **`saturn-qemu`** variant exists (`nix/nixos/saturn-qemu.nix`) and is
> the safe place to validate the service, API, script rewrite, and (headless
> caveats aside) the systemd wiring before touching the real HTPC. The OSD-over-
> Kodi test, however, ultimately needs the real box + display.

---

## 10. Risks / gotchas / open questions

- **Session dependency (audio + X)** — the main fiddly bit, now *bigger* than
  before because both `pactl` **and** the OSD need the live uid-1000 session
  (unlike ALSA, which was session-independent). Mitigated by autologin +
  `Restart=on-failure`. **If flaky, run the whole thing as a systemd *user*
  service** for `reinis` (`systemd.user.services.saturn-volume` +
  `loginctl enable-linger reinis`) so it inherits `DISPLAY`/`XDG_RUNTIME_DIR`
  and starts/stops with the session. This is arguably the *cleaner* default
  given the X dependency — decide at implementation time.
- **OSD over fullscreen Kodi** — the single biggest technical risk (see §5).
  Plan B is `picom`; plan C is `volnoti` or Kodi's native OSD. **Test first.**
- **systemd sandboxing vs X/Pulse sockets** — over-tight hardening will silently
  break `pactl` (needs `/run/user/1000`) or the OSD (needs `/tmp/.X11-unix`).
  Start permissive; it's a LAN toy.
- **Keyboard now depends on the service** — media keys are dead if the service is
  down (§7b). Accepted trade-off for shared OSD + single source of truth.
- **No auth is a real (small) exposure** — anyone on the LAN can change volume.
  Acceptable per requirements; subnet-scoped firewall keeps it off the VPN/other
  interfaces. (Future: a static token as `?k=` if ever wanted.)
- **Default sink assumption** — `@DEFAULT_AUDIO_SINK@` is whatever Pulse routes
  to the TV/HDMI. Verify with `pactl list sinks short` on saturn; if the wrong
  sink is default (e.g. after an HDMI hotplug), volume would target the wrong
  device. The `sink` option lets you pin a specific sink name if needed.
- **i3blocks backend consistency** — i3blocks uses a `[volume-pulseaudio]` block,
  so moving the service to `pactl` makes them agree (this is a fix). Confirm the
  block still updates on `pkill -RTMIN+10 i3blocks` after the change.
- **Concurrent access** (media key + web at once) — both hit the same default
  sink via `pactl`; last write wins, next read is truthful, OSD reflects final.
- **`i3-volume-control` install path on NixOS** — verify it actually lands on
  PATH after the rewrite (§8 open item), not just symlinked for the Debian flow.
- **Preset values** (25/50/75) — confirm against real room levels; one-line
  tweaks in the `presets` option.
- **Port 8899** — double-check nothing else grabs it.

---

## 11. Explicit scope (what this is / isn't)

**In scope**: one NixOS-defined HTTP service on saturn using **`pactl`** on the
default sink as the **single source of truth**; GET read + POST
set/up/down/mute returning real volume; **presets 25/50/75, no cap**; a static
dark web page (presets + granular + mute); the **rewritten `i3-volume-control`**
media-key client; an **on-screen `xob` volume OSD** (large bar, ~1000ms, over
fullscreen video) fired centrally on every change; subnet-scoped firewall;
low-latency tuning.

**Out of scope (for now)**: native Android app; authentication; multi-host /
per-app volume; auto-discovery/mDNS; HTTPS; per-application volume; showing
*live* changes on the phone beyond the next request's response (the TV OSD is
the shared live feedback).
