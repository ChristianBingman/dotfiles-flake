# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, home-manager, ... }:
let
  vars = {
    username = "christian";
    homedir = "/home/christian";
    gituser = "ChristianBingman";
    gitemail = "christianbingman@gmail.com";
  };
in{
  imports = [
    ../../modules/wol-vm-controller
  ];
  services.immich = {
    enable = true;
    machine-learning.enable = true;
    machine-learning.environment = {
      IMMICH_HOST = lib.mkForce "0.0.0.0";
    };
    redis.enable = false;
    database.enable = false;
  };
  systemd.services.immich-server.enable = false;
  services.wol-vm-controller = {
    enable = true;
    startMac = "52:54:00:4d:7f:e8";
    shutdownMac = "10:7c:61:3d:34:c1";
    vmName = "win11";
    openFirewall = true;
  };
  home-manager.users.christian = import ../../home.nix { inherit pkgs lib vars; };

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
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.package = pkgs.steam.override {
    extraPkgs = pkgs: [ pkgs.libsForQt5.qt5.qtmultimedia ];
  };
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.kernelParams = [ "nohibernate" "amd_iommu=on" "iommu=pt" "pcie_acs_override=downstream,multifunction" ];
  networking.hostId = "073fdb3a";
  boot.supportedFilesystems = [ "zfs" ];
  #boot.zfs.extraPools = [ "jbod1" ];
  users.users.proxmox = {
    shell = "${pkgs.shadow}/bin/nologin";
    group = "users";
    isNormalUser = true;
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "invalid users" = [
          "root"
        ];
        "passwd program" = "/run/wrappers/bin/passwd %u";
        security = "user";
      };
      Proxmox = {
        path = "/mnt/proxmox";
        "guest ok" = "no";
        "read only" = "no";
        "browseable" = "no";
        "inherit acls" = "no";
        "inherit permissions" = "no";
        "ea support" = "yes";
        "store dos attributes" = "no";
        "vfs objects" = "fruit streams_xattr";
        printable = "no";
        "create mask" = "0664";
        "force create mode" = "0664";
        "directory mask" = "0775";
        "force directory mode" = "0775";
        "hide special files" = "no";
        "follow symlinks" = "yes";
        "hide dot files" = "yes";
        "valid users" = "proxmox";
        "read list" = "proxmox";
        "write list" = "proxmox";
        "invalid users" = "";
      };
    };
  };
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    applications = {
      apps = [
        {
          name = "1080p BigPicture";
          output = "/home/christian/sunshine-output.txt";
          prep-cmd = [
            {
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-0,1920x1080@60,auto,1";
            }
          ];
          detached = [
              "capsh --delamb=cap_sys_admin -- -c \"setsid steam steam://open/bigpicture\""
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
        {
          name = "4k BigPicture";
          output = "/home/christian/sunshine-output.txt";
          prep-cmd = [
            {
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-0,3840x2160@60,auto,1";
            }
          ];
          detached = [
              "capsh --delamb=cap_sys_admin -- -c \"setsid steam steam://open/bigpicture\""
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
        {
          name = "Ultrawide 1440p Desktop";
          output = "/home/christian/sunshine-output.txt";
          prep-cmd = [
            {
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-0,3440x1440@90,auto,1.25";
            }
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
        {
          name = "Macbook Desktop";
          output = "/home/christian/sunshine-output.txt";
          prep-cmd = [
            {
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-0,2560x1600@60,auto,1.25";
            }
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };
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
  sops.secrets.mongo_env = { sopsFile = ../../secrets/x53.yaml; };
  sops.templates."x53-smb-secrets".content = ''
    username=${config.sops.placeholder."smb/username"}
    password=${config.sops.placeholder."smb/password"}
  '';
  networking = {
    vlans = {
      guest0 = {
        id = 100;
        interface = "eth0";
      };
    };
    bridges = {
      vmbr0 = {
        interfaces = ["eth0"];
      };
    };
    useDHCP = false;
    hostName = "x23";
    usePredictableInterfaceNames = false;
    defaultGateway = "10.2.0.1";
    nameservers = [ "10.2.0.1" "8.8.8.8" ];
    interfaces.guest0.ipv4.addresses = [
    {
      prefixLength = 24;
      address = "10.5.0.2";
    }
    ];
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
  networking.firewall.allowedTCPPorts = [ 22 3003 5800 19999 8443 8080 8843 8880 6789 ];
  networking.firewall.allowedUDPPorts = [ 3478 10001 1900 5514 ];
  networking.firewall.interfaces.guest0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 67 68 53 ];
  };
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
  fileSystems."/mnt/tubearchivist" = {
    device = "//ironman.christianbingman.com/DockerBackup/Kubernetes/tubearchivist-tubearchivist-media-pvc-bc9447d8-48e8-4081-8d2a-f7414c430577";
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
    #ollama-rocm
    heroic
    umu-launcher
    dnsmasq
    virt-manager
  ];

  services.ollama = {
    enable = true;
    openFirewall = true;
    package = pkgs.ollama-rocm;
    host = "0.0.0.0";
    loadModels = ["gpt-oss:20b"];
    rocmOverrideGfx = "11.0.0";
    environmentVariables = {
      OLLAMA_NUM_PARALLEL = "2";
    };
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

    oci-containers.containers.mongodb = {
      image = "docker.io/mongo:7.0-jammy";
      hostname = "mongo";
      autoStart = true;
      volumes = [
        "/var/lib/mongo/db:/data/db"
        "/var/lib/mongo/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh:ro"
      ];
      environmentFiles = [ config.sops.secrets.mongo_env.path ];
    };
    oci-containers.containers.unifi-controller = {
      image = "lscr.io/linuxserver/unifi-network-application:latest";
      autoStart = true;
      hostname = "unifi-network-application";
      volumes = [
        "/var/lib/unifi-network-application:/config"
      ];
      ports = [
        "8443:8443"
        "3478:3478/udp"
        "10001:10001/udp"
        "8080:8080"
        "1900:1900/udp"
        "8843:8843"
        "8880:8880"
        "6789:6789"
        "5514:5514/udp"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "America/Chicago";
        MONGO_HOST = "mongo";
        MONGO_PORT = "27017";
      };
      environmentFiles = [ config.sops.secrets.mongo_env.path];
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
        "--device=/dev/sg0"
      ];
      ports = [
        "5800:5800"
      ];
    };
  };
  sops.secrets."elasticsearch_pass" = { sopsFile = ../../secrets/x53.yaml; };
  sops.templates."elasticsearch_config.json".content = builtins.toJSON {
    filebeat = {
      inputs = [
        {
          type = "journald";
          id = "everything";
        }
      ];
    };
    logging = {
      level = "warning";
    };
    output = {
      elasticsearch = {
        hosts = [ "elasticsearch-int.christianbingman.com:9200" ];
        username = "elastic";
        password = config.sops.placeholder."elasticsearch_pass";
      };
    };
    setup.ilm = {
      enabled = true;
      rollover_alias = "syslog-%{[agent.version]}";
      pattern = "{now/d}-000001";
      policy_name = "syslog-30d";
    };
  };

  services.filebeat.enable = lib.mkDefault true;

  systemd.services.filebeat.serviceConfig.ExecStart = lib.mkForce ''
    ${pkgs.filebeat}/bin/filebeat -e \
      -c '${config.sops.templates."elasticsearch_config.json".path}' \
      --path.data '/var/lib/filebeat'
  '';
}

