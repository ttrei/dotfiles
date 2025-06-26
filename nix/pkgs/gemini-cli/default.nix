# https://github.com/NixOS/nixpkgs/pull/419945
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  writeShellApplication,
  cacert,
  common-updater-scripts,
  curl,
  gnused,
  jq,
  prefetch-npm-deps,
}:

let
  pname = "gemini-cli";
  version = "0.1.5";
in
buildNpmPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    # Currently there's no release tag
    rev = "121bba346411cce23e350b833dc5857ea2239f2f";
    hash = "sha256-2w28N6Fhm6k3wdTYtKH4uLPBIOdELd/aRFDs8UMWMmU=";
  };

  npmDepsHash = "sha256-yoUAOo8OwUWG0gyI5AdwfRFzSZvSCd3HYzzpJRvdbiM=";

  fixupPhase = ''
    runHook preFixup

    # Remove broken symlinks
    find $out -type l -exec test ! -e {} \; -delete 2>/dev/null || true

    mkdir -p "$out/bin"
    ln -sf "$out/lib/node_modules/@google/gemini-cli/bundle/gemini.js" "$out/bin/gemini"

    patchShebangs "$out/bin" "$out/lib/node_modules/@google/gemini-cli/bundle/"

    runHook postFixup
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "gemini-cli-update-script";
    runtimeInputs = [
      cacert
      common-updater-scripts
      curl
      gnused
      jq
      prefetch-npm-deps
    ];
    text = ''
      latest_version=$(curl -s "https://raw.githubusercontent.com/google-gemini/gemini-cli/main/package-lock.json" | jq -r '.version')
      update-source-version gemini-cli "$latest_version" --rev="$latest_rev"

      temp_dir=$(mktemp -d)
      curl -s "https://raw.githubusercontent.com/google-gemini/gemini-cli/main/package-lock.json" > "$temp_dir/package-lock.json"
      npm_deps_hash=$(prefetch-npm-deps "$temp_dir/package-lock.json")
      sed -i "s|npmDepsHash = \".*\";|npmDepsHash = \"$npm_deps_hash\";|" "pkgs/by-name/ge/gemini-cli/package.nix"
      rm -rf "$temp_dir"
    '';
  });

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ donteatoreo ];
    platforms = lib.platforms.all;
    mainProgram = "gemini";
  };
}
