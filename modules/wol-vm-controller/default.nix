{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.wol-vm-controller;
  
  wol-vm-controller = pkgs.python3.pkgs.buildPythonApplication {
    pname = "wol-vm-controller";
    version = "1.0.0";
    format = "other";

    src = ./.;

    installPhase = ''
      mkdir -p $out/bin
      cp wol_vm_controller.py $out/bin/wol-vm-controller
      chmod +x $out/bin/wol-vm-controller
      
      # Fix shebang to use Nix python3
      substituteInPlace $out/bin/wol-vm-controller \
        --replace "#!/usr/bin/env python3" "#!${pkgs.python3}/bin/python3 -u"
    '';

    meta = with lib; {
      description = "Wake-on-LAN listener for controlling libvirt VMs";
      license = licenses.mit;
      maintainers = [ ];
      mainProgram = "wol-vm-controller";
    };
  };
in
{
  options.services.wol-vm-controller = {
    enable = mkEnableOption "Wake-on-LAN VM Controller";

    startMac = mkOption {
      type = types.str;
      default = "52:54:00:4d:7f:e8";
      description = "MAC address that triggers VM start";
      example = "52:54:00:4d:7f:e8";
    };

    shutdownMac = mkOption {
      type = types.str;
      default = "10:7c:61:3d:34:c1";
      description = "MAC address that triggers VM shutdown";
      example = "10:7c:61:3d:34:c1";
    };

    port = mkOption {
      type = types.port;
      default = 9;
      description = "UDP port to listen for WoL packets";
    };

    vmName = mkOption {
      type = types.str;
      default = "win11";
      description = "Name of the libvirt VM to control";
      example = "win11";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the WoL port in the firewall";
    };
  };

  config = mkIf cfg.enable {
    # Add package to system
    environment.systemPackages = [ wol-vm-controller ];

    # Open firewall if requested
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ cfg.port ];

    # Create systemd service
    systemd.services.wol-vm-controller = {
      description = "Wake-on-LAN VM Controller";
      after = [ "network.target" "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${wol-vm-controller}/bin/wol-vm-controller \
            --start-mac ${cfg.startMac} \
            --shutdown-mac ${cfg.shutdownMac} \
            --port ${toString cfg.port} \
            --vm-name ${cfg.vmName} \
            --virsh-path ${pkgs.libvirt}/bin/virsh
        '';
        Restart = "always";
        RestartSec = "10s";

        # Security hardening
        DynamicUser = false; # Needs access to libvirt socket
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
      };
    };
  };
}

