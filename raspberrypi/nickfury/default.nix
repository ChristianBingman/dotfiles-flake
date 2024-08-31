{ config, lib, pkgs, ... }:
let
  hid-pidff = pkgs.callPackage ../../derivations/hid-pidff.nix { kernel = pkgs.linuxPackages_rpi4.kernel; };
in {
  imports = [ ../../modules/usbipd.nix ];
  services.usbipd.enable = true;
  services.usbipd.devices = [ "044f:b660" "346e:0004" ];

  networking = {
    hostName = "nickfury";
    interfaces.eth0.useDHCP = false;
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.7";
      }
    ];
    firewall.interfaces.eth0.allowedTCPPorts = [ 22 19999 ];
  };

  boot.extraModulePackages = [ hid-pidff config.boot.kernelPackages.usbip ];
}
