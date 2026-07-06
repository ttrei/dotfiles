{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.saturnVolume;

  runtimeDir = "/run/user/${toString cfg.uid}";
  fallbackBaseUrl = "http://${cfg.lanAddress}:${toString cfg.port}";

  serverArgs = [
    "${./volume/volume_server.py}"
    "--host"
    cfg.bindAddress
    "--port"
    (toString cfg.port)
    "--step"
    (toString cfg.step)
    "--sink"
    cfg.sink
    "--index"
    "${./volume/index.html}"
    "--fallback-base-url"
    fallbackBaseUrl
    "--preset-low"
    (toString cfg.presets.low)
    "--preset-mid"
    (toString cfg.presets.mid)
    "--preset-high"
    (toString cfg.presets.high)
  ]
  ++ lib.optionals cfg.osd.enable [
    "--osd-fifo"
    cfg.osd.fifo
  ]
  ++ lib.optionals (!cfg.refreshI3Blocks) [ "--no-refresh-i3blocks" ];

  volumeServer = pkgs.writeShellApplication {
    name = "saturn-volume-server";
    runtimeInputs = [
      pkgs.procps
      pkgs.pulseaudio
      pkgs.python3
    ];
    text = ''
      exec python3 ${lib.escapeShellArgs serverArgs}
    '';
  };

  i3VolumeControl = pkgs.writeShellApplication {
    name = "i3-volume-control";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      default_base="http://127.0.0.1:${toString cfg.port}"
      base="''${SATURN_VOLUME_BASE:-$default_base}"

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
      fifo=${lib.escapeShellArg cfg.osd.fifo}
      fifo_dir="$(dirname "$fifo")"

      mkdir -p "$fifo_dir"
      if [ -e "$fifo" ] && [ ! -p "$fifo" ]; then
        rm -f "$fifo"
      fi
      if [ ! -p "$fifo" ]; then
        mkfifo "$fifo"
      fi
      chmod 600 "$fifo"

      tail -f "$fifo" | xob -t ${toString cfg.osd.timeoutMs} -s saturn
    '';
  };
in
{
  options.services.saturnVolume = {
    enable = lib.mkEnableOption "Saturn LAN volume control service";

    user = lib.mkOption {
      type = lib.types.str;
      default = "reinis";
      description = "User whose PulseAudio and X11 session should be controlled.";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "UID of the session user, used for XDG_RUNTIME_DIR.";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = "/home/reinis";
      description = "Home directory of the session user, used for XAUTHORITY.";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address the HTTP service binds to.";
    };

    lanAddress = lib.mkOption {
      type = lib.types.str;
      default = "192.168.8.205";
      description = "LAN address advertised to the phone UI when opened outside HTTP.";
    };

    lanSubnet = lib.mkOption {
      type = lib.types.str;
      default = "192.168.8.0/24";
      description = "IPv4 subnet allowed through the firewall to the HTTP service.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8899;
      description = "HTTP port for the volume API and phone page.";
    };

    step = lib.mkOption {
      type = lib.types.ints.between 1 100;
      default = 1;
      description = "Relative volume step, in percent, for up/down actions.";
    };

    sink = lib.mkOption {
      type = lib.types.str;
      default = "@DEFAULT_SINK@";
      description = "PulseAudio sink passed to pactl.";
    };

    display = lib.mkOption {
      type = lib.types.str;
      default = ":0";
      description = "X11 display used by the OSD.";
    };

    refreshI3Blocks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to signal i3blocks after mutating the volume.";
    };

    presets = {
      low = lib.mkOption {
        type = lib.types.ints.between 0 100;
        default = 25;
        description = "Low preset volume percentage.";
      };

      mid = lib.mkOption {
        type = lib.types.ints.between 0 100;
        default = 50;
        description = "Mid preset volume percentage.";
      };

      high = lib.mkOption {
        type = lib.types.ints.between 0 100;
        default = 75;
        description = "High preset volume percentage.";
      };
    };

    osd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to show an xob on-screen volume bar after each mutation.";
      };

      timeoutMs = lib.mkOption {
        type = lib.types.ints.between 1 60000;
        default = 1000;
        description = "xob timeout, in milliseconds.";
      };

      fifo = lib.mkOption {
        type = lib.types.str;
        default = "/run/user/1000/xob.fifo";
        description = "FIFO written by the HTTP service and read by xob.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      i3VolumeControl
      pkgs.curl
      volumeServer
    ]
    ++ lib.optionals cfg.osd.enable [ pkgs.xob ];

    networking.firewall.extraCommands = lib.mkAfter ''
      ${pkgs.iptables}/bin/iptables -C nixos-fw \
        -p tcp \
        -s ${cfg.lanSubnet} \
        --dport ${toString cfg.port} \
        -j nixos-fw-accept 2>/dev/null || \
        ${pkgs.iptables}/bin/iptables -A nixos-fw \
          -p tcp \
          -s ${cfg.lanSubnet} \
          --dport ${toString cfg.port} \
          -j nixos-fw-accept
    '';

    networking.firewall.extraStopCommands = lib.mkAfter ''
      ${pkgs.iptables}/bin/iptables -D nixos-fw \
        -p tcp \
        -s ${cfg.lanSubnet} \
        --dport ${toString cfg.port} \
        -j nixos-fw-accept 2>/dev/null || true
    '';

    systemd.services.saturn-volume = {
      description = "Saturn volume HTTP API";
      wantedBy = [ "multi-user.target" ];
      after = [ "display-manager.service" ];
      wants = lib.optionals cfg.osd.enable [ "saturn-volume-osd.service" ];
      environment = {
        DISPLAY = cfg.display;
        HOME = cfg.home;
        XAUTHORITY = "${cfg.home}/.Xauthority";
        XDG_RUNTIME_DIR = runtimeDir;
      };
      serviceConfig = {
        ExecStart = "${volumeServer}/bin/saturn-volume-server";
        User = cfg.user;
        Restart = "on-failure";
        RestartSec = "2s";
        NoNewPrivileges = true;
      };
    };

    systemd.services.saturn-volume-osd = lib.mkIf cfg.osd.enable {
      description = "Saturn xob volume OSD";
      wantedBy = [ "multi-user.target" ];
      after = [ "display-manager.service" ];
      environment = {
        DISPLAY = cfg.display;
        HOME = cfg.home;
        XAUTHORITY = "${cfg.home}/.Xauthority";
        XDG_CONFIG_HOME = "${xobConfigHome}";
        XDG_RUNTIME_DIR = runtimeDir;
      };
      serviceConfig = {
        ExecStart = "${osdRunner}/bin/saturn-volume-osd";
        User = cfg.user;
        Restart = "always";
        RestartSec = "2s";
        NoNewPrivileges = true;
      };
    };
  };
}
