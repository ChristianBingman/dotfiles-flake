# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/wol-vm-controller
  ];
  services.wol-vm-controller = {
    enable = true;
    startMac = "52:54:00:4d:7f:e8";
    shutdownMac = "10:7c:61:3d:34:c1";
    vmName = "win11";
    openFirewall = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [
    "kvm-amd"
    "sg"
    "uinput"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "vfio_virqfd"
  ];
  hardware.enableRedistributableFirmware = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.kernelParams = [ "nohibernate" "amd_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" ];
  networking.hostId = "073fdb3a";
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "jbod1" ];
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };
  #services.xserver = {
  #  desktopManager.gnome.enable = true;
  #  displayManager.gdm.enable = true;
  #  displayManager.gdm.wayland = true;
  #};
  programs.hyprland = {
    enable = true;
  };
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "christian";
  };
  nixpkgs.config.allowUnfree = true;
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/40F5-F4EC";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
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
    bridges = {
      vmbr0 = {
        interfaces = ["eth0"];
      };
    };
    useDHCP = false;
    hostName = "x23";
    usePredictableInterfaceNames = false;
    defaultGateway = "10.2.0.1";
    nameservers = [ "10.2.0.1" ];
    interfaces.vmbr0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.52";
      }
    ];
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 5800 19999 ];
  fileSystems."/mnt/movies" = {
    device = "//ironman.christianbingman.com/General/Movies";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };
  fileSystems."/mnt/tnpg" = {
    device = "//ironman.christianbingman.com/DockerBackup/Kubernetes/tnpg-stack-tnpg-shared-storage-pvc-93864959-a768-4132-b11d-8f3dcf0617da";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };
  fileSystems."/home/christian/Development" = {
    device = "//ironman.christianbingman.com/HumanTorchDev";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };
  fileSystems."/home/christian/Documents" = {
    device = "//ironman.christianbingman.com/General/Documents";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };
  users.users.christian.extraGroups = [ "wheel" "podman" "uinput" ];
  hardware.uinput.enable = true;

  services.jellyfin.enable = true;
  services.jellyfin.openFirewall = true;
  environment.systemPackages = with pkgs; [
    hyprpaper
    whitesur-cursors
    dmidecode
    # Non-KDE graphical packages
    hardinfo2 # System information and benchmarks for Linux systems

    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    git
    talosctl
    kubectl
    terraform
    rocmPackages.rocminfo
    rocmPackages.rocm-smi
    rocmPackages.rocm-core
    ollama-rocm
    heroic
    umu-launcher
    dnsmasq
    virt-manager
  ];

  services.ollama = {
    enable = true;
    openFirewall = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    loadModels = ["gpt-oss:20b"];
    rocmOverrideGfx = "11.0.0";
  };
  #programs.ssh.startAgent = true;
  networking.firewall.trustedInterfaces = [ "podman0" ];

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
      hooks.qemu.win11hook = ../../config/libvirtd/win11hook.sh;
    };
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

