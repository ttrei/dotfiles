{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    unstable.godot_4
    unstable.vscode-fhs
  ];
}
