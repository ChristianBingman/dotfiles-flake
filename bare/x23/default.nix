# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, home-manager, inputs, ... }:
let
  vars = {
    username = "christian";
    homedir = "/home/christian";
    gituser = "ChristianBingman";
    gitemail = "christianbingman@gmail.com";
  };
  # Shared sync logic used both by the udev-triggered plug-in sync and the
  # nightly timer. Takes the iPod data partition's device path as $1.
  ipodSyncScript = pkgs.writeShellScript "ipod-sync" ''
    set -euo pipefail

    dev="$1"
    mnt="/mnt/ipod"
    src_music="/mnt/music"
    src_podcasts="/mnt/podgrab"

    if [ -z "$(${pkgs.coreutils}/bin/ls -A "$src_music" 2>/dev/null)" ]; then
      echo "ipod-sync: $src_music is empty or unavailable, aborting" >&2
      exit 1
    fi

    if [ -z "$(${pkgs.coreutils}/bin/ls -A "$src_podcasts" 2>/dev/null)" ]; then
      echo "ipod-sync: $src_podcasts is empty or unavailable, aborting" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$mnt"
    ${pkgs.util-linux}/bin/mount "$dev" "$mnt"
    cleanup() { ${pkgs.util-linux}/bin/umount "$mnt" || true; }
    trap cleanup EXIT

    ${pkgs.coreutils}/bin/mkdir -p "$mnt/FLACs"
    ${pkgs.coreutils}/bin/mkdir -p "$mnt/Podcasts"
    ${pkgs.rsync}/bin/rsync -rtXv --delete --modify-window=2 "$src_music"/ "$mnt"/FLACs/
    ${pkgs.rsync}/bin/rsync -rtXv --delete --modify-window=2 "$src_podcasts"/ "$mnt"/Podcasts/
    ${pkgs.coreutils}/bin/sync
  '';
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
  home-manager.users.christian = import ../../home.nix { inherit pkgs lib vars inputs; };
  home-manager.backupFileExtension = "bak";

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
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-1,1920x1080@60,auto,1";
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
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-1,3840x2160@60,auto,1";
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
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-1,3440x1440@90,auto,1.25";
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
              do = "${pkgs.util-linux}/bin/setsid ${pkgs.hyprland}/bin/hyprctl -i 0 keyword monitor HDMI-A-1,2560x1600@60,auto,1.25";
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
  networking.firewall.allowedUDPPorts = [ 1900 3478 7359 10001 1900 5514 ];
  fileSystems."/mnt/music" = {
    device = "//ironman.christianbingman.com/General/Music";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
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
  fileSystems."/mnt/pinchflat" = {
    device = "//ironman.christianbingman.com/DockerBackup/Kubernetes/pinchflat-pinchflat-downloads-pvc-9424cefb-fcef-48dd-b520-2e321f2a0379";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };
  fileSystems."/mnt/tubearchivist" = {
    device = "//ironman.christianbingman.com/DockerBackup/Kubernetes/archived-tubearchivist-tubearchivist-media-pvc-bc9447d8-48e8-4081-8d2a-f7414c430577";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=1000,gid=100,credentials=${config.sops.templates."x53-smb-secrets".path}"];
  };
  fileSystems."/mnt/podgrab" = {
    device = "//ironman.christianbingman.com/DockerBackup/Kubernetes/podgrab-podgrab-podcasts-pvc-702a992f-927b-4d3f-b844-4c3d221d3188";
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
    virt-manager
    asunder
  ];

  services.ollama = {
    enable = false;
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

  # --- Auto-sync the FLAC library to the iPod on plug-in --------------------
  # When the iPod's FAT32 data partition appears (udev reports its 11-char
  # label "CHRIS'S IPOD" as ID_FS_LABEL=CHRIS'S_IPO), udev tags its device
  # unit so that ipod-sync@<kernel-name>.service is pulled in. The service
  # mounts it, rsyncs /mnt/music -> <ipod>/FLACs, then unmounts.
  systemd.services."ipod-sync@" = {
    description = "Sync FLAC library to iPod (/dev/%i)";
    # Make sure the SMB source automount is ordered before us; the script
    # also refuses to run if the source turns up empty, so a failed network
    # mount can never let --delete wipe the iPod.
    unitConfig.RequiresMountsFor = "/mnt/music";
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "2h";
      ExecStart = "${ipodSyncScript} /dev/%i";
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="vfat", ENV{ID_FS_LABEL}=="CHRIS'S_IPO", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ipod-sync@%k.service"
  '';

  # --- Also sync nightly at 2am, but only if the iPod happens to be plugged
  # in already (e.g. left connected overnight). Looks up the partition by
  # its actual filesystem label (spaces, not udev's underscore-encoded
  # form) and skips quietly -- rather than failing -- when it's absent.
  systemd.services.ipod-sync-nightly = {
    description = "Nightly sync of FLAC library to iPod, if plugged in";
    unitConfig.RequiresMountsFor = "/mnt/music";
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "2h";
      ExecStart = "${pkgs.writeShellScript "ipod-sync-nightly" ''
        set -euo pipefail

        dev="$(${pkgs.util-linux}/bin/blkid -L "CHRIS'S IPO" 2>/dev/null || true)"
        if [ -z "$dev" ]; then
          echo "ipod-sync-nightly: iPod not plugged in, skipping" >&2
          exit 0
        fi

        exec ${ipodSyncScript} "$dev"
      ''}";
    };
  };

  systemd.timers.ipod-sync-nightly = {
    description = "Nightly iPod sync timer (2am, only if plugged in)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "02:00";
      # Don't catch up on a missed run at boot -- the iPod being plugged in
      # right now is exactly what we can't infer from a missed schedule.
      Persistent = false;
    };
  };

}

