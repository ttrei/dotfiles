{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Inspired by https://gitlab.com/LongerHV/nixos-configuration
  #
  # Overview of the nix neovim ecosystem:
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/doc/languages-frameworks/vim.section.md
  # permalink: https://github.com/NixOS/nixpkgs/blob/5f64a12a728902226210bf01d25ec6cbb9d9265b/doc/languages-frameworks/vim.section.md

  programs.neovim = {
    enable = true;
    # Manage Neovim plugins (and more!) with Nix and Home Manager
    # https://gist.github.com/nat-418/d76586da7a5d113ab90578ed56069509
    # Advanced Neovim configuration with Nix and Home Manager
    # https://gist.github.com/nat-418/493d40b807132d2643a7058188bff1ca
    # What if your favourite Vim plugin isn’t already packaged?
    # https://github.com/NixOS/nixpkgs/blob/5f64a12a728902226210bf01d25ec6cbb9d9265b/doc/languages-frameworks/vim.section.md#what-if-your-favourite-vim-plugin-isnt-already-packaged-what-if-your-favourite-vim-plugin-isnt-already-packaged
    plugins = let
      vim-asciidoc-folding = pkgs.vimUtils.buildVimPlugin {
        name = "vim-asciidoc-folding";
        src = builtins.fetchGit {
          url = "https://github.com/matcatc/vim-asciidoc-folding.git";
          rev = "7925af137f7c36bb54acaafc268643548f04e5e8";
        };
      };
      # NOTE(2024-09-03): avante.nvim needs to build some stuff with :AvanteBuild
      # I patched the source to build it in a tmp directory but that didn't help.
      # Had to install cargo, pkg-config, openssl and export PKG_CONFIG_PATH=/nix/store/...-openssl-3.0.14-dev/lib/pkgconfig
      # avante-nvim seems to expect that the build is executed in the plugin directory, but that's not possible if the
      # plugin is located in the nix store.
      # TODO: Check out if nixvim will get the avante plugin: https://github.com/nix-community/nixvim/issues/2096
      # TODO: Try to package avante.nvim for nix.
      # codesnap-nvim build seems similar to what we need:
      # https://github.com/NixOS/nixpkgs/blob/a5317c333836e433cb10547fe907c402ec77c77e/pkgs/applications/editors/vim/plugins/overrides.nix#L432

      # avante-nvim = pkgs.vimUtils.buildVimPlugin {
      #     name = "avante-nvim";
      #     src = pkgs.fetchFromGitHub {
      #         owner = "yetone";
      #         repo = "avante.nvim";
      #         rev = "713cb403d0e3c3b9b8b9cacb1ca0ff5d6fc35a7d";
      #         hash = "sha256-AQX2uDKEWfrHXSte6/DcIBeRBd+6Maj/QOYNeFS1+I4=";
      #     };
      # };

      avante-nvim =
        let
          version = "0.0.1-reinis";
          src = pkgs.fetchFromGitHub {
            owner = "yetone";
            repo = "avante.nvim";
            rev = "19a7d84d1e2d294fc071840bf1cc27e0a0b10c78";
            hash = "sha256-gOd+1uHtHGlNOiVl2lx2t+75GYfYFxcQapA7i6xy+OQ=";
          };
          avante-lib = pkgs.unstable.rustPlatform.buildRustPackage rec {
            pname = "avante-lib";
            inherit version src;
            sourceRoot = "${src.name}";
            cargoLock = {
              lockFile = ./avante.nvim-Cargo.lock;
              outputHashes = {
                 "mlua-0.10.0-beta.1" = "sha256-ZEZFATVldwj0pmlmi0s5VT0eABA15qKhgjmganrhGBY=";
              };
            };

            nativeBuildInputs = [
              pkgs.pkg-config
              pkgs.openssl
            ];

            # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md#custom-buildinstall-procedures-custom-buildinstall-procedures
            # permalink: https://github.com/NixOS/nixpkgs/blob/caf129c3c44620b07d88b09399b3745ba08e9caa/doc/languages-frameworks/rust.section.md#custom-buildinstall-procedures-custom-buildinstall-procedures

            buildPhase = ''
              # export HOME=$(pwd)
              export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
              make BUILD_FROM_SOURCE=true
              # export HOME=$(pwd)
              # export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
              # cargo build --release --features=luajit -p avante-tokenizers
            '';

            installPhase = ''
              mkdir -p $out
              cp -r build $out
            '';

            doCheck = false;
          };
        in
        pkgs.vimUtils.buildVimPlugin {
          pname = "avante.nvim";
          inherit version src;

          postInstall = ''
            mkdir -p $out
            cp -r ${avante-lib}/build $out
          '';
        };


      nvim-treesitter-with-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (treesitter-plugins:
        with treesitter-plugins; [
          bash
          beancount
          c # required by nvim-treesitter
          cpp
          dockerfile
          java
          json
          lua # required by nvim-treesitter
          make
          markdown
          nix
          org
          query # required by nvim-treesitter
          python
          sql
          vim # required by nvim-treesitter
          vimdoc # required by nvim-treesitter
          yaml
          zig
        ]);
    in
      with pkgs.vimPlugins; [
        # NOTE (2023-12-27)
        # Explored if I want to use lazy.vim instead of packer.
        # Now I'm thinking that I don't need to use a non-nix package manager at all.
        # Dropped packer.
        # In case I will try to use lazy in addition to nix in the future, a workaround might be necessary for managing
        # plugins with lazy.vim while managing config with home-manager:
        # https://github.com/nix-community/home-manager/issues/257#issuecomment-831300021
        # found that suggestion here:
        # https://www.reddit.com/r/NixOS/comments/108fwwh/tradeoffs_of_using_home_manager_for_neovim_plugins/j3sa16n/
        # https://www.reddit.com/r/NixOS/comments/104l0w9/how_to_get_lua_files_in_neovim_on_hm/j362asl/?context=3
        #
        # lazy-nvim


        # Take a plugin from unstable packages
        # NOTE(2024-09-03): neovim and all vimPlugins come from unstable for now (see overlays/default.nix)
        # pkgs.unstable.vimPlugins.img-clip-nvim

        # TODO
        # harpoon

        ### colors
        # gruvbox
        gruvbox-material

        ### syntax, LSP
        cmp-nvim-lsp
        luasnip
        cmp-buffer
        cmp_luasnip
        cmp-path

        # Official plugin, written in vimscript (https://github.com/github/copilot.vim)
        # copilot-vim
        # Integration with nvim-cmp (looks unmaintained: https://github.com/hrsh7th/cmp-copilot)
        # cmp-copilot

        # Rewrite of copilot-vim in lua
        # Seems a bit buggy for python: https://github.com/zbirenbaum/copilot-cmp/issues/10
        copilot-lua
        # Integration with nvim-cmp
        copilot-cmp

        # https://github.com/nvim-neorg/nixpkgs-neorg-overlay
        neorg

        neomake
        nvim-cmp
        nvim-lspconfig
        nvim-treesitter-with-plugins
        nvim-treesitter-context
        nvim-treesitter-textobjects
        vim-nix
        # # These should be handled by treesitter, right?
        # xml.vim
        # vim-javascript
        # vim-markdown

        # dingllm
        plenary-nvim

        ### other
        vim-beancount
        fastfold
        fzf-lua
        # # I will go with fzf-lua for now - people say it has better performance than telescope.
        # # But should re-visit this decision if I notice some telescope feature I really want.
        # telescope-nvim
        undotree
        vim-fugitive
        vim-table-mode
        vim-visual-star-search
        vim-asciidoc-folding

        img-clip-nvim
        avante-nvim
      ];
  };

  home.file = {
    ".config/nvim" = {
      recursive = true;
      source = ./nvim;
    };
  };
}
