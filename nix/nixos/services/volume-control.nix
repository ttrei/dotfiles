{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 8899;
  user = "reinis";
  runtimeDir = "/run/user/1000";
  osdFifo = "${runtimeDir}/xob.fifo";

  # The QEMU guest is isolated behind jupiter's LAN-scoped firewall. Real
  # saturn is directly connected to the LAN and restricts the port itself.
  allowedSubnet =
    if config.networking.hostName == "saturn-qemu" then "0.0.0.0/0" else "192.168.8.0/24";

  volumeFiles = pkgs.runCommand "saturn-volume-files" { } ''
    mkdir -p "$out"
    cp ${./volume/volume_server.py} "$out/volume_server.py"
    cp ${./volume/index.html} "$out/index.html"
  '';

  volumeServer = pkgs.writeShellApplication {
    name = "saturn-volume-server";
    runtimeInputs = [
      pkgs.procps
      pkgs.pulseaudio
      pkgs.python3
    ];
    text = ''
      exec python3 ${volumeFiles}/volume_server.py
    '';
  };

  i3VolumeControl = pkgs.writeShellApplication {
    name = "i3-volume-control";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      base="http://127.0.0.1:${toString port}"

      usage() {
        echo "Usage: $0 [up|down|mute|set PERCENTAGE]" >&2
      }

      post() {
        curl -fsS --connect-timeout 1 --max-time 2 -X POST "$1" >/dev/null
      }

      case "''${1:-}" in
        up)
          post "$base/volume/up"
          ;;
        down)
          post "$base/volume/down"
          ;;
        mute)
          post "$base/volume/mute"
          ;;
        set)
          if [ -z "''${2:-}" ]; then
            usage
            exit 1
          fi
          post "$base/volume/set?v=''${2}"
          ;;
        *)
          usage
          exit 1
          ;;
      esac
    '';
  };

  xobConfigHome = pkgs.runCommand "saturn-xob-config" { } ''
    mkdir -p "$out/xob"
    cp ${./volume/xob-styles.cfg} "$out/xob/styles.cfg"
  '';

  osdRunner = pkgs.writeShellApplication {
    name = "saturn-volume-osd";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.xob
    ];
    text = ''
      fifo=${lib.escapeShellArg osdFifo}

      mkdir -p "$(dirname "$fifo")"
      if [ -e "$fifo" ] && [ ! -p "$fifo" ]; then
        rm -f "$fifo"
      fi
      if [ ! -p "$fifo" ]; then
        mkfifo "$fifo"
      fi
      chmod 600 "$fifo"

      tail -f "$fifo" | xob -t 1000 -s saturn
    '';
  };
in
{
  environment.systemPackages = [
    i3VolumeControl
    pkgs.curl
    pkgs.xob
    volumeServer
  ];

  networking.firewall.extraCommands = lib.mkAfter ''
    ${pkgs.iptables}/bin/iptables -C nixos-fw \
      -p tcp \
      -s ${allowedSubnet} \
      --dport ${toString port} \
      -j nixos-fw-accept 2>/dev/null || \
      ${pkgs.iptables}/bin/iptables -A nixos-fw \
        -p tcp \
        -s ${allowedSubnet} \
        --dport ${toString port} \
        -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = lib.mkAfter ''
    ${pkgs.iptables}/bin/iptables -D nixos-fw \
      -p tcp \
      -s ${allowedSubnet} \
      --dport ${toString port} \
      -j nixos-fw-accept 2>/dev/null || true
  '';

  systemd.services.saturn-volume = {
    description = "Saturn volume HTTP API";
    wantedBy = [ "multi-user.target" ];
    after = [ "display-manager.service" ];
    wants = [ "saturn-volume-osd.service" ];
    environment = {
      DISPLAY = ":0";
      HOME = "/home/${user}";
      XAUTHORITY = "/home/${user}/.Xauthority";
      XDG_RUNTIME_DIR = runtimeDir;
    };
    serviceConfig = {
      ExecStart = "${volumeServer}/bin/saturn-volume-server";
      User = user;
      Restart = "on-failure";
      RestartSec = "2s";
      NoNewPrivileges = true;
    };
  };

  systemd.services.saturn-volume-osd = {
    description = "Saturn xob volume OSD";
    wantedBy = [ "multi-user.target" ];
    after = [ "display-manager.service" ];
    environment = {
      DISPLAY = ":0";
      HOME = "/home/${user}";
      XAUTHORITY = "/home/${user}/.Xauthority";
      XDG_CONFIG_HOME = "${xobConfigHome}";
      XDG_RUNTIME_DIR = runtimeDir;
    };
    serviceConfig = {
      ExecStart = "${osdRunner}/bin/saturn-volume-osd";
      User = user;
      Restart = "always";
      RestartSec = "2s";
      NoNewPrivileges = true;
    };
  };
}
