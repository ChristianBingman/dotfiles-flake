# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets."smb/username" = { sopsFile = ../../secrets/x53.yaml; };
  sops.secrets."smb/password" = { sopsFile = ../../secrets/x53.yaml; };
  sops.templates."x53-smb-secrets".content = ''
    username=${config.sops.placeholder."smb/username"}
    password=${config.sops.placeholder."smb/password"}
  '';
  networking = {
    hostName = "x53";
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.52";
      }
    ];
  };
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 5800 19999 ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.kernelModules = ["sg"];

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
    autoResize = true;
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "ext4";
    autoResize = true;
  };
  fileSystems."/mnt/movies" = {
    device = "//ironman.christianbingman.com/General/Movies";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };

  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.ollama = {
    enable = true;
    openFirewall = true;
    acceleration = "cuda";
  };

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers.makemkv = {
      image = "docker.io/jlesage/makemkv:latest";
      hostname = "makemkv";
      autoStart = true;
      volumes = [
        "/mnt/movies:/output"
        "/home/nixos/storage:/storage"
        "/home/nixos/config:/config"
      ];
      environment = {
        AUTO_DISC_RIPPER = "1";
        AUTO_DISC_RIPPER_EJECT = "1";
        MAKEMKV_KEY = "T-iyhMMBV8nWtNo3BgMdcvypH8UL01nYmww2zFzQDtiZsdJUOaAuCURsPRQ1Hj3i75RE";
      };
      extraOptions = [
        "--device=/dev/sr0"
        "--device=/dev/sg2"
      ];
      ports = [
        "5800:5800"
      ];
    };
  };
}

