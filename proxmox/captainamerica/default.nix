# This has been deprecated in favor of using kubernetes
{ config, lib, pkgs, ... }:
let
  homepage-services = builtins.toJSON [
    {
      Status = [
        {
          Proxmox = {
            href = "https://doctorstrange.christianbingman.com:8006";
            description = "Proxmox Node 1";
            siteMonitor = "https://doctorstrange.christianbingman.com:8006";
            widget = {
              type = "proxmox";
              url = "https://doctorstrange.christianbingman.com:8006";
              username = "################";
              password = "####################################";
              node = "doctorstrange";
            };
          };
        }
        {
          Proxmox = {
            href = "https://buckybarnes.christianbingman.com:8006";
            description = "Proxmox Node 2";
            siteMonitor = "https://buckybarnes.christianbingman.com:8006";
            widget = {
              type = "proxmox";
              url = "https://buckybarnes.christianbingman.com:8006";
              username = "################";
              password = "####################################";
              node = "buckybarnes";
            };
          };
        }
        {
          Proxmox = {
            href = "https://professorx.christianbingman.com:8006";
            description = "Proxmox Node 3";
            siteMonitor = "https://professorx.christianbingman.com:8006";
            widget = {
              type = "proxmox";
              url = "https://professorx.christianbingman.com:8006";
              username = "################";
              password = "####################################";
              node = "professorx";
            };
          };
        }
        {
          Grafana = {
            href = "http://grafana.christianbingman.com";
            description = "Grafana";
            siteMonitor = "http://grafana.christianbingman.com";
            widget = {
              type = "grafana";
              url = "http://grafana.christianbingman.com";
              username = "######";
              password = "###############";
            };
          };
        }
        {
          Unifi = {
            href = "http://captainamerica.christianbingman.com:8443";
            description = "Unifi";
            siteMonitor = "http://captainamerica.christianbingman.com:8443";
            widget = {
              type = "unifi";
              url = "https://captainamerica.christianbingman.com:8443";
              username = "######";
              password = "###############";
            };
          };
        }
        {
          "Home Assistant" = {
            href = "http://homeassistant.christianbingman.com";
            description = "Home Assistant";
            siteMonitor = "http://homeassistant.christianbingman.com:8123";
            widget = {
              type = "homeassistant";
              url = "http://homeassistant.christianbingman.com:8123";
              key = "#######################################################################################################################################################################################";
            };
          };
        }
        {
          "WAN Usage" = {
            href = "http://wolverine.christianbingman.com:19999";
            widget = {
              type = "glances";
              url = "http://wolverine.christianbingman.com:61208";
              metric = "network:eth0";
            };
          };
        }
        {
          "Prometheus" = {
            siteMonitor = "http://host.containers.internal:9090";
            widget = {
              type = "prometheus";
              url = "http://host.containers.internal:9090";
            };
          };
        }
      ];
    }
  ];
  homepage-settings = builtins.toJSON {
    title = "Sanctum Sanctorum";
    startUrl = "http://homepage.christianbingman.com";
    providers = {
      openweathermap = "################################";
    };
    color = "violet";
    theme = "dark";
    headerStyle = "clean";
    target = "_self";
    hideVersion = true;
    showStats = false;
    statusStyle = "dot";
    background = {
      image = "https://images.unsplash.com/photo-1581373449483-37449f962b6c?q=80&w=2938&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
      blur = "sm";
      brightness = 50;
    };
    layout = {
      Status = {
        style = "row";
        columns = 3;
      };
    };
  };
  homepage-widgets = builtins.toJSON [
    {
      resources = {
        cpu = false;
        memory = false;
        disk = false;
      };
    }
    {
      search = {
        provider = "google";
        target = "_self";
      };
    }
    {
      datetime = {
        text_size = "xl";
        format = {
          timeStyle = "short";
        };
      };
    }
    {
      openweathermap = {
        label = "Chicago";
        latitude = "42.0126";
        longitude = "87.6746";
        units = "metric";
        provider = "openweathermap";
        cache = 5;
        format = {
          maximumFractionDigits = 1;
        };
      };
    }
  ];
in{
  networking = {
    hostName = "captainamerica";
    interfaces.eth0.ipv4.addresses = [
      {
        prefixLength = 24;
        address = "10.2.0.5";
      }
    ];
  };
  networking.firewall.trustedInterfaces = [ "podman0" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  nixpkgs.config.allowUnfree = true;
  #nixpkgs.overlays = [ 
  #  (final: prev: {
  #    homepage-dashboard = prev.homepage-dashboard.overrideAttrs (old: {env.HOMEPAGE_CONFIG_DIR = "/etc/homepage-dashboard";});
  #    }
  #  )
  #];

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
      groups = [ "wheel" ];
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
    htop
    cifs-utils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  services.grafana = {
    enable = true;
    dataDir = "/mnt/grafana";
    settings.server = {
      http_port = 3000;
      http_addr = "127.0.0.1";
      protocol = "http";
      domain = "grafana.christianbingman.com";
    };
    settings.log.level = "warn";
    settings.database.wal = true;
    settings."auth.anonymous" = {
      enabled = true;
      org_name = "Main Org.";
      org_role = "Viewer";
    };
    settings."auth.basic".enabled = true;
  };
  systemd.services.grafana = {
    after = [ "network.target" ];
    wants = [ "network.target" ];
  };
  services.nginx.enable = true;
  services.nginx.virtualHosts.${toString config.services.grafana.settings.server.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
    locations."/api/live" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
  };

  services.nginx.virtualHosts."registry.christianbingman.com" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
  };

  services.nginx.virtualHosts."homepage.christianbingman.com" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8082";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "0.0.0.0";
    scrapeConfigs = [
      {
        job_name = "netdata_all_hosts";
        scrape_interval = "15s";
        metrics_path = "/api/v1/allmetrics";
        honor_labels = true;
        params = {
          format = [ "prometheus" ];
        };
        static_configs = [{
          targets = [
            "thor.christianbingman.com:19999"
            "captainamerica.christianbingman.com:19999"
            "nightcrawler.christianbingman.com:19999"
            "humantorch.christianbingman.com:19999"
            "ironman.christianbingman.com:19999"
            "wolverine.christianbingman.com:19999"
            "professorx.christianbingman.com:19999"
            "doctorstrange.christianbingman.com:19999"
            "buckybarnes.christianbingman.com:19999"
          ];
        }];
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 22 80 443 5044 19999 ];
  networking.firewall.enable = true;

  # List services that you want to enable:


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 22 ];
  #networking.firewall.extraCommands = ''
  #  iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
  #  iptables -A OUTPUT -d 10.2.0.1 -p udp -m udp --dport 53 -j ACCEPT
  #  iptables -A OUTPUT -d 10.2.0.1/24 -j DROP
  #'';

  environment.etc = {
    captainamerica-smb-secrets = {
      text = ''
        username=##############
        password=#########################
      '';
      mode = "0600";
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers.unifi-controller = {
      image = "docker.io/jacobalberty/unifi:v7.5.176";
      hostname = "unifi-controller";
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ   = "America/Chicago";
      };
      volumes = [
        "/mnt/unifi:/unifi"
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
    };

    oci-containers.containers.homepage-dashboard = {
      image = "ghcr.io/gethomepage/homepage:latest";
      hostname = "homepage";
      ports = [ "8082:3000" ];
      volumes = [ 
        "${pkgs.writeText "settings.yaml" homepage-settings}:/app/config/settings.yaml:ro"
        "${pkgs.writeText "services.yaml" homepage-services}:/app/config/services.yaml:ro"
        "${pkgs.writeText "widgets.yaml" homepage-widgets}:/app/config/widgets.yaml:ro"
        "${pkgs.lib.cleanSource ../../config/Background.jpg}:/app/config/images/background.jpg:ro"
      ];
      autoStart = true;
      environment = {
        TZ = "America/Chicago";
      };
    };
  };

  users.users.christian.extraGroups = [ "wheel" "docker" "podman" ];

  fileSystems."/mnt/unifi" = {
    device = "//ironman.christianbingman.com/DockerBackup/unifi";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,credentials=/etc/captainamerica-smb-secrets"];
  };
  fileSystems."/mnt/grafana" = {
    device = "//ironman.christianbingman.com/DockerBackup/grafana";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=196,gid=998,credentials=/etc/captainamerica-smb-secrets"];
  };

  system.activationScripts.update-mnt-perms.text = ''
    chmod 755 /mnt
  '';

  fileSystems."/var/lib/prometheus2" = {
    device = "//ironman.christianbingman.com/DockerBackup/prometheus";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=255,gid=255,credentials=/etc/captainamerica-smb-secrets"];
  };

  fileSystems."/var/lib/docker-registry" = {
    device = "//ironman.christianbingman.com/DockerBackup/registry";
    fsType = "cifs";
    options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},mfsymlinks,uid=998,gid=998,credentials=/etc/captainamerica-smb-secrets"];
  };

  services.dockerRegistry = {
    enable = true;
    listenAddress = "0.0.0.0";
  };

  services.logstash = {
    enable = true;
    inputConfig = ''
      beats {
        port => 5044
        host => "10.2.0.5"
      }
    '';
    outputConfig = ''
      if [@metadata][pipeline] {
        elasticsearch {
        hosts => ["elasticsearch.christianbingman.com:80"]
        manage_template => false
        index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        pipeline => "%{[@metadata][pipeline]}"
        }
      } else {
        elasticsearch {
        hosts => ["elasticsearch.christianbingman.com:80"]
        manage_template => false
        index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        }
      }
    '';
  };

  systemd.services.grafana.serviceConfig.RestartSec = 90;
}

