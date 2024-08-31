# This machine has been deprecated due to lack of great support for VR
# and numerous technical issues
{ config, lib, pkgs, ... }:
let
  hid-pidff = pkgs.callPackage ../../derivations/hid-pidff.nix {};
in {
  imports = [ ../../modules/usbip.nix ];
  services.usbip.enable = true;
  services.usbip.host = "nickfury.christianbingman.com";
  services.usbip.devices = [ "044f:b660" "346e:0004" ];
  programs.nix-ld.enable = true;

  networking = {
    hostName = "thor";
    defaultGateway = "10.2.0.1";
    nameservers = [ "10.2.0.1" ];
    interfaces."eth0" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          prefixLength = 24;
          address = "10.2.0.2";
        }
      ];
    };
    firewall.interfaces.eth0.allowedTCPPorts = [ 22 9943 9944 19999 47984 47989 48010 ];
    firewall.interfaces.eth0.allowedUDPPorts = [ 9943 9944 47998 47999 48000 ];
  };
  nixpkgs.config.allowUnfree = true;

  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.xserver.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{idVendor}=="044f", ATTRS{idProduct}=="b66e", MODE="0660", TAG+="uaccess", RUN+="${pkgs.linuxConsoleTools}/bin/evdev-joystick --evdev %E{DEVNAME} --deadzone 0"
    SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666"
  '';

  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;
  services.xrdp.defaultWindowManager = "startxfce4";

  #services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager = {
    xfce.enable = true;
  };
  services.displayManager = {
    defaultSession = "xfce";
    sddm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "christian";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  hardware.graphics.enable32Bit = true;
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.pulseaudio.enable = true;

  environment.systemPackages = with pkgs; [
    protontricks
    firefox
    alvr
  ];

  users.users.christian.extraGroups = [ "wheel" "audio" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ hid-pidff config.boot.kernelPackages.usbip ];
  boot.kernelParams = [ "module_blacklist=i915" ];

  systemd.user.services = {
    sunshine = {
      description = "Sunshine is a Game stream host for Moonlight.";
      serviceConfig.ExecStart = "${pkgs.sunshine}/bin/sunshine";
      serviceConfig.Restart = "on-failure";
      wantedBy = [ "graphical-session.target" ];
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";                                  
      fsType = "ext4";
    };
  services.filebeat.enable = false;
}
