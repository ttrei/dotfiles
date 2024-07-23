{
  config,
  pkgs,
  ...
}: {
  users.users.reinis = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = ["networkmanager" "transmission" "wheel" "audio" "realtime" "input" "dialout"];
    # mkpasswd -m sha-512
    hashedPassword = "$6$Cg9okSaCqojkhWfc$/EOP6PeEaL5DPnjjNtG7k7.80O5X8Sc4Q2qiTQzS1n6vn.DTp3fI5dafofJzbU/MwFTnroSMg3CT8towxuUwG.";
  };
}
