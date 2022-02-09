{ pkgs, nixpkgs, config, lib, ... }:
{

  nixpkgs.config.packageOverrides = pkgs: {
    xow = pkgs.xow.overrideAttrs (orig: {
      version = "pre-1.0.25";
      buildInputs = [ inputs.libusb.packages.x86_64-linux.libusb ];
    });
  };

  home.packages = with pkgs; [
    # https://dee.underscore.world/blog/home-manager-flakes/
    (pkgs.writeScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
    direnv
    emacs
    fd
    fzf
    lorri
    git
    git-crypt
    ripgrep
    xow
  ];

  programs.bash = {
    enable = false;
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
