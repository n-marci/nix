{ lib, ... }:

{
  powerManagement.powertop.enable = true;
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
  services.fstrim.enable = true;
  # zram swap (info: https://libreddit.tiekoetter.com/r/linux/comments/11dkhz7/zswap_vs_zram_in_2023_whats_the_actual_practical/ ) 
  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;
  boot.kernel.sysctl = { "vm.swappiness" = lib.mkForce 80; };
}
