# Saturn volume control

A small LAN volume remote for the Saturn HTPC. The NixOS module runs one HTTP
service as `reinis`; it serves the phone-friendly web page and changes the
default PulseAudio sink with `pactl`.

Volume changes from the web page and `i3-volume-control` use the same API. After
each change, the service refreshes i3blocks and writes the resulting volume to
a persistent `xob` process, which displays the TV volume OSD.

The implementation is intentionally specific to Saturn: port `8899`, 1% steps,
25/50/75% presets, user/UID `reinis`/`1000`, and the default PulseAudio sink are
hardcoded.

## Test with `saturn-qemu`

From the repository root, build and start the VM:

```bash
bin/saturn-qemu-build.sh
bin/saturn-qemu-run.sh
```

Log into the VM's graphical session as `reinis`. A graphical login is required
because PulseAudio and the `xob` OSD use that user's X11 session.

### Smoke-test inside the VM

Check PulseAudio and both services:

```bash
pactl list short sinks
systemctl status saturn-volume saturn-volume-osd
```

Exercise the API:

```bash
curl http://127.0.0.1:8899/volume
curl -X POST 'http://127.0.0.1:8899/volume/set?v=50'
curl -X POST http://127.0.0.1:8899/volume/up
curl -X POST http://127.0.0.1:8899/volume/down
curl -X POST http://127.0.0.1:8899/volume/mute
```

Successful API responses look like:

```json
{"volume":50,"muted":false}
```

Confirm that mutations change the VM audio, update the i3 volume display, and
show an OSD bar in the VM window. Test the keyboard client too:

```bash
i3-volume-control up
i3-volume-control down
i3-volume-control mute
```

To test VM audio through the host speakers:

```bash
speaker-test -D default -c 2 -t sine
```

Stop it with `Ctrl-C`.

### Test from the VM host

QEMU forwards host port `8899` to the VM. On the host, open:

```text
http://127.0.0.1:8899
```

Or test it without a browser:

```bash
curl http://127.0.0.1:8899/volume
curl -X POST http://127.0.0.1:8899/volume/up
```

If a request fails, inspect the VM logs:

```bash
journalctl -u saturn-volume -u saturn-volume-osd -b --no-pager
```
