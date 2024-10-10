# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "template";
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.5";
      }
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 19999 ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "ext4";
  };
}

