# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "nightcrawler";
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.9";
      }
    ];
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.util-linux}/bin/dmesg";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl status";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/journalctl";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" "docker" "podman" ];
    }];
    extraConfig = ''
      Defaults secure_path=${lib.makeBinPath [
        pkgs.systemd
        pkgs.util-linux
      ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cloudflared
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 19999 ];
  networking.firewall.extraCommands = ''
    iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -d 10.2.0.1 -p udp -m udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -d 10.2.0.1/24 -j DROP
  '';

  environment.etc = {
    tunnel-creds = {
      source = lib.cleanSource ./tunnel-creds.json;
      user = "cloudflared";
      mode = "0600";
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers.website = {
      image = "docker.io/christianbingman/website:latest";
      hostname = "website";
      autoStart = true;
      ports = [ "80:80" ];
    };
  };

  services.cloudflared.enable = true;
  services.cloudflared.tunnels = {
    "####################################" = {
      default = "http_status:404";
      credentialsFile = "/etc/tunnel-creds";
      ingress = {
        "christianbingman.com" = {
          service = "http://localhost:80";
        };
        "www.christianbingman.com" = {
          service = "http://localhost:80";
        };
      };
    };
  };
}

