{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.usbipd;
  device = types.submodule {
    options = {
      productid = mkOption {
        type = types.str;
      };
      vendorid = mkOption {
        type = types.str;
      };
    };
  };
in {
  options.services.usbipd = {
    enable = mkEnableOption "usbip server";
    kernelModule = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.usbip;
    };
    devices = mkOption {
      type = types.listOf device;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.kernelModule ];
    boot.kernelModules = [ "usbip-core" "usbip-host" ];
    networking.firewall.allowedTCPPorts = [ 3240 ];
    services.udev.extraRules = strings.concatLines 
      ((map (dev: 
        "ACTION==\"add\", SUBSYSTEM==\"usb\", ATTRS{idProduct}==\"${dev.productid}\", ATTRS{idVendor}==\"${dev.vendorid}\", RUN+=\"${pkgs.systemd}/bin/systemctl restart usbip-${dev.vendorid}:${dev.productid}.service\"") cfg.devices));

    systemd.services = (builtins.listToAttrs (map (dev: { name = "usbip-${dev.vendorid}:${dev.productid}"; value = {
          after = [ "usbipd.service" ];
          script = ''
            set +e
            devices=$(${cfg.kernelModule}/bin/usbip list -l | grep -E "^.*- busid.*(${dev.vendorid}:${dev.productid})" )
            output=$(${cfg.kernelModule}/bin/usbip -d bind -b $(echo $devices | ${pkgs.gawk}/bin/awk '{ print $3 }') 2>&1)
            code=$?

            echo $output
            if [[ $output =~ "already bound" ]]; then
              exit 0
            else
              exit $code
            fi
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
