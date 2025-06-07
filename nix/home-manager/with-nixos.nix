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

  programs.bash = {
    enable = true;
    # Unlimited history (there's also some config/code in .bashrc.legacy below)
    # https://stackoverflow.com/a/12234989/9124671
    historySize = -1;
    historyFileSize = -1;
    # initExtra = ''
    #   # This is probably needed if we want to add extra env variables
    #   # https://discourse.nixos.org/t/home-manager-doesnt-seem-to-recognize-sessionvariables/8488/7
    #   . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    # '';
    profileExtra = ''
      source ~/.profile.legacy
    '';
    bashrcExtra = ''
      source ~/.bashrc.legacy
    '';
  };

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
