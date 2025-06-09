{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  programs.firefox = {
    # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.enable

    # This works, but I want my firefox profile to persist between sessions
    # Do some research on how to persist stuff:
    # https://github.com/Misterio77/nix-starter-configs/tree/0537107ce41396dff1fb1dd43705a94e9120f576#try-opt-in-persistance
    # https://github.com/Misterio77/nix-config/blob/0ecfa1af537a70bbf4f4607501073d368e31612f/home/misterio/features/desktop/common/firefox.nix#L37
    enable = false;
    profiles.reinis = {
      id = 0;
      name = "Reinis";
      isDefault = true;
      search.default = "DuckDuckGo";
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bypass-paywalls-clean
      ];
      userChrome = builtins.readFile includes/userChrome.css;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

}
