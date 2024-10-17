# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  kubeMasterHostname = "kube-master-dev";
  api = "https://${kubeMasterHostname}:6443";
in
{
  networking = {
    hostName = "kube-worker-dev-1";
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.37";
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

  environment.systemPackages = with pkgs; [
    kubernetes
  ];

  services.kubernetes = {
    roles = ["node"];
    masterAddress = kubeMasterHostname;
    easyCerts = true;

    kubelet.kubeconfig.server = api;
    apiserverAddress = api;

    addons.dns.enable = true;
  };
}

