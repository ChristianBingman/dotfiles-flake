# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  kubeMasterIP = "10.2.0.36";
  kubeMasterHostname = "kube-master-dev";
  kubeMasterAPIServerPort = 6443;
in {
  networking = {
    hostName = kubeMasterHostname;
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = kubeMasterIP;
      }
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 6443 8888 19999 ];
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
  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;
    flannel.enable = true;
  };
}

