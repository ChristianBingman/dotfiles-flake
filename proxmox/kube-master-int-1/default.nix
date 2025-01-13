# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  kubeMasterIP = "10.2.0.36";
  kubeMasterHostname = "kube-master-int-1";
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

  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";


  services.kubernetes = {
    roles = ["master"];
    apiserver = {
      advertiseAddress = kubeMasterIP;  
    };
  };

}

