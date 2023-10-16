{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  i3pyblocks = inputs.i3pyblocks.overlay;
  neorg = inputs.neorg-overlay.overlays.default;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # See examples here:
  # https://github.com/Misterio77/nix-config/blob/d39c4bfa163ab6ecccf2affded0a3e5ad4b8cc7b/overlays/default.nix
  modifications = final: prev: {
    bazarr = final.unstable.bazarr;
    jackett = final.unstable.jackett;
    navidrome = final.unstable.navidrome;
    sonarr = final.unstable.sonarr;
    radarr = final.unstable.radarr.overrideAttrs (oldAttrs: rec {
      version = "4.4.2.6956";
      src = prev.fetchurl {
        url = "https://github.com/Radarr/Radarr/releases/download/v${version}/Radarr.develop.${version}.linux-core-x64.tar.gz";
        sha256 = "sha256-DVVBJC7gGjlF9S3KI0+9kh4EzDEoWsC2jJxD8khbN2c=";
      };
    });

    comma = final.unstable.comma;

    # # neovim 0.8.1 of nixpkgs-22.11 has some problems with the copilot plugin
    # # Update 2023-06-08:
    # # Disabled this modification after switching to next release (23.05).
    # # Leaving it here for future reference.
    # neovim-unwrapped = final.unstable.neovim-unwrapped;
    # vimPlugins = final.unstable.vimPlugins;

    arcanPackages = prev.arcanPackages.overrideScope' (finalScope: prevScope: {
      arcan = prevScope.arcan.overrideAttrs (finalAttrs: prevAttrs: {
        version = "85c8564bdbee8468a5716bea64daf1d78937ffbf";

        src = final.fetchFromGitHub {
          owner = "letoram";
          repo = "arcan";
          rev = "85c8564bdbee8468a5716bea64daf1d78937ffbf";
          hash = "sha256-etmj1vpZTjxbmr4UiLBEK57WFJ1NeEnY5WfBYajX3ls=";
        };

        patches = [];
      });
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
