# gcc environments don't work

`nix-shell` pulls in the default compiler and overrides the one we have selected. You can use
`nix run` instead:

    $ nix run -f channel:nixpkgs-unstable gcc5
