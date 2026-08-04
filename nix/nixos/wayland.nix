{
  config,
  lib,
  pkgs,
  ...
}:
let
  makeScreenshotCommand =
    {
      name,
      desktopName,
      runtimeInputs ? [ pkgs.niri ],
      text,
    }:
    let
      command = pkgs.writeShellApplication {
        inherit name runtimeInputs text;
      };
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [
        command
        (pkgs.makeDesktopItem {
          inherit name desktopName;
          exec = "${command}/bin/${name}";
          icon = "camera-photo";
          categories = [ "Utility" ];
        })
      ];
    };
in
{
  environment.systemPackages = with pkgs; [
    mako
    waybar
    wl-clipboard
    wofi

    (makeScreenshotCommand {
      name = "screenshot";
      desktopName = "Screenshot";
      text = ''
        niri msg action screenshot --show-pointer=false
      '';
    })
    (makeScreenshotCommand {
      name = "screenshot-screen";
      desktopName = "Screenshot Screen";
      text = ''
        niri msg action screenshot-screen --show-pointer=false
      '';
    })
    (makeScreenshotCommand {
      name = "screenshot-window";
      desktopName = "Screenshot Window";
      runtimeInputs = [
        niri
        jq
      ];
      text = ''
        window_id="$(niri msg --json pick-window | jq -er '.id')"
        niri msg action screenshot-window \
          --id="$window_id" \
          --show-pointer=false
      '';
    })
  ];

  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
}
