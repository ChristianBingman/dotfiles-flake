# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, sops, ... }:

{
  sops.defaultSopsFile = ../../secrets/humantorch.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets."smb/username" = {};
  sops.secrets."smb/password" = {};
  sops.templates."humantorch-smb-secrets".content = ''
    username=${config.sops.placeholder."smb/username"}
    password=${config.sops.placeholder."smb/password"}
  '';
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  programs.ssh.startAgent = true;
  networking = {
    hostName = "humantorch";
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.6";
      }
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 19999 3001 ];
  networking.firewall.trustedInterfaces = [ "podman0" ];

  environment.systemPackages = with pkgs; [
    git
    talosctl
    kubectl
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };
  fileSystems."/home/christian/Development" = {
    device = "//ironman.christianbingman.com/HumanTorchDev";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."humantorch-smb-secrets".path}"];
  };

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
      #dockerCompat = true;
      #dockerSocket.enable = true;
    };
    docker = {
      enable = true;
    };
  };

  users.users.christian.extraGroups = [ "wheel" "podman" "docker" ];
}

