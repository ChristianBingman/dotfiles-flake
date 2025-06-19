{ config, lib, pkgs, ... }:
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.mongo_user = { sopsFile = ../../secrets/northstar.yaml; };
  sops.secrets.mongo_pass = { sopsFile = ../../secrets/northstar.yaml; };
  sops.templates."mongodb.env".content = ''
    MONGO_INITDB_ROOT_USERNAME=${config.sops.placeholder.mongo_user}
    MONGO_INITDB_ROOT_PASSWORD='${config.sops.placeholder.mongo_pass}'
  '';
  sops.templates."unifi.env".content = ''
    MONGO_USER=${config.sops.placeholder.mongo_user}
    MONGO_PASS='${config.sops.placeholder.mongo_pass}'
  '';
  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers.unifi-controller = {
      image = "lscr.io/linuxserver/unifi-network-application:latest";
      hostname = "unifi-controller";
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ   = "America/Chicago";
        MONGO_HOST = "unifi-db";
        MONGO_PORT = "27017";
        MONGO_DBNAME = "unifi";
        MONGO_AUTHSOURCE = "admin";
      };
      volumes = [
        "/home/nixos/unifi:/config"
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
      environmentFiles = [
        "${config.sops.templates."unifi.env".path}"
      ];
    };
    oci-containers.containers.mongo-unifi-db = {
      image = "docker.io/mongo:4.4.18";
      hostname = "unifi-db";
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ   = "America/Chicago";
      };
      environmentFiles = [
        "${config.sops.templates."mongodb.env".path}"
      ];
      volumes = [
        "/home/nixos/db:/data/db"
      ];
    };
  };

  users.users.christian.extraGroups = [ "wheel" "docker" "podman" ];
  networking = {
    hostName = "northstar";
    firewall.allowedTCPPorts = [ 22 19999 ];
    defaultGateway = "192.168.1.254";
    interfaces.eth0.useDHCP = false;
    nameservers = [ "100.65.68.55" "8.8.8.8" ];
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "192.168.1.10";
      }
    ];
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
}
