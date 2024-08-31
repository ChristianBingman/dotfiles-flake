{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.usbipd;
in {
  options.services.usbipd = {
    enable = mkEnableOption "usbip server";
    kernelModule = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.usbip;
    };
    devices = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.kernelModule ];
    boot.kernelModules = [ "usbip-core" "usbip-host" ];
    networking.firewall.allowedTCPPorts = [ 3240 ];
    systemd.services = (builtins.listToAttrs (map (dev: { name = "usbip-${dev}"; value = {
          after = [ "usbipd.service" ];
          requiredBy = [ "usbipd.service" ];
          script = ''
            devices=$(${cfg.kernelModule}/bin/usbip list -l | grep -E "^.*- busid.*(${dev})" )
            ${cfg.kernelModule}/bin/usbip -d bind -b $(echo $devices | ${pkgs.gawk}/bin/awk '{ print $3 }')
          '';
          preStop = ''
            devices=$(${cfg.kernelModule}/bin/usbip list -l | grep -E "^.*- busid.*(${dev})" )
            ${cfg.kernelModule}/bin/usbip -d unbind -b $(echo $devices | ${pkgs.gawk}/bin/awk '{ print $3 }')
          '';
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          restartTriggers = [ "usbipd.service" ];
        };
      }) cfg.devices)) // {
        usbipd = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig.ExecStart = "${cfg.kernelModule}/bin/usbipd -D";
          serviceConfig.Type = "forking";
        };
      };
  };
}
