{ config, lib, ... }:
{

  # Enable fstrim, which tracks free space on SSDs for garbage collection
  # More info: https://www.reddit.com/r/NixOS/comments/rbzhb1/if_you_have_a_ssd_dont_forget_to_enable_fstrim/
  services.fstrim.enable = lib.mkIf config.physical true;
}
