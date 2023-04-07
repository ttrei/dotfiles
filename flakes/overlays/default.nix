{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  i3pyblocks = inputs.i3pyblocks.overlay;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    bazarr = final.unstable.bazarr;
    jackett = final.unstable.jackett;
    navidrome = final.unstable.navidrome;
    radarr = final.unstable.radarr;
    sonarr = final.unstable.sonarr;

    # neovim 0.8.1 of nixpkgs-22.11 has some problems with the copilot plugin
    neovim-unwrapped = final.unstable.neovim-unwrapped;
    vimPlugins = final.unstable.vimPlugins;
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
