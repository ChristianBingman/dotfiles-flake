{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.usbip;
in {
  options.services.usbip = {
    enable = mkEnableOption "usbip client";
    kernelModule = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.usbip;
    };
    devices = mkOption {
      type = types.listOf types.str;
      default = [];
    };
    host = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.kernelModule ];
    boot.kernelModules = [ "vhci-hcd" ];
    systemd.services = (builtins.listToAttrs (map (dev: { name = "usbip-${dev}"; value = {
          wantedBy = [ "network.target" ];
          script = ''
            devices=$(${cfg.kernelModule}/bin/usbip list -r ${cfg.host} | grep -E ".*(${dev})" )
            ${cfg.kernelModule}/bin/usbip -d attach -r ${cfg.host} -b $(echo $devices | ${pkgs.gawk}/bin/awk '{ print substr($1, 1, length($1)-1) }')
          '';
          preStop = ''
            devices=$(${cfg.kernelModule}/bin/usbip port | grep -B 1 -E ".*(${dev})" | grep "Port" )
            ${cfg.kernelModule}/bin/usbip -d detach -p $(echo $devices | ${pkgs.gawk}/bin/awk '{ print substr($2, 1, length($2)-1) }')
          '';
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
        };
      }) cfg.devices));
  };
}
