{ config, lib, pkgs, ... }:
let
in {
  networking = {
    hostName = "nickfury";
    defaultGateway = "10.2.0.1";
    interfaces.eth0.useDHCP = false;
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.7";
      }
    ];
    firewall.interfaces.eth0.allowedTCPPorts = [ 22 19999 ];
  };
}
