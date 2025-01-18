{ config, lib, pkgs, sops-nix, ... }:
let
  hostname = "wolverine";
  lan_ip = "10.2.0.1";
  lan_ipv6 = "fd00::1";
  wan_interface = "eth0";
  lan_interface = "eth1";
  dns_servers = [ "1.1.1.1" "8.8.8.8" ];
  dhcp_ranges = [ 
    "10.2.0.75,10.2.0.254,255.255.255.0,6h"
    "fd00::02,fd00::ff,12h"
  ];
  domain = "christianbingman.com";
  hosts = pkgs.writeText "dnsmasq_hosts"
  ''
    ${lan_ip} ${hostname} ${domain}
    ${lan_ipv6} ${hostname} ${domain}
    10.2.0.2  thor # Gaming VM
    10.2.0.3  hulk # Hyper HDR Living Room TV
    10.2.0.4  sentry # Living Room P2P
    10.2.0.5  prov # Provisioning host
    10.2.0.6  humantorch # NixOS Dev VM
    10.2.0.7  nickfury # Desk RPI
    10.2.0.8  ironman # CM3588 Storage
    10.2.0.9  nightcrawler # Proxmox Cluster 4
    10.2.0.10 iceman # Home Assistant
    10.2.0.11 professorx # Proxmox Cluster 1
    10.2.0.12 buckybarnes # Proxmox Cluster 2
    10.2.0.13 doctorstrange # Proxmox Cluster 3
    10.2.0.14 jeangrey # Kitchen Cabinets WLED
    10.2.0.15 rogue # Rome Crystal WLED
    10.2.0.16 emmafrost # TV Backlight WLED
    10.2.0.17 thing # Wave Office WLED
    10.2.0.18 blackbolt # Hallway PIR Sensor
    10.2.0.19 namor # Hallway PIR Sensor
    10.2.0.20 beast # Kube VIP
    10.2.0.21 blackpanther # Kube Control Planes
    10.2.0.22 blackpanther # Kube Control Planes
    10.2.0.23 blackpanther # Kube Control Planes
    # 10.2.0.25-35 MetalLB Prod
    10.2.0.25 photoprism # Photoprism
    10.2.0.26 internal-proxy # Kube general internal proxy
    10.2.0.29 registry # Docker registry
    # End MetalLB
    10.2.0.36 kube-master-int
    10.2.0.37 kube-worker-int-1
    10.2.0.38 kube-worker-int-2
    10.2.0.39 kube-worker-int-3
    # 10.2.0.40-50 MetalLB Int
    10.2.0.40 elasticsearch-int
    10.2.0.41 kube-int-ingress
    10.2.0.43 mosquitto
    # End MetalLB
    10.2.0.51 shangchi # Gaming windows VM
    10.2.0.52 x53 # NVIDIA VM
    10.2.0.53 cloak # Meraki MS350
  '';
  cnames = [
    "transmission.${domain},ironman"
    "homeassistant.${domain},iceman"
    "grafana.int.${domain},kube-int-ingress"
    "argocd.int.${domain},kube-int-ingress"
    "www.int.${domain},kube-int-ingress"
    "search.int.${domain},kube-int-ingress"
    "anki.int.${domain},kube-int-ingress"
    "frigate.int.${domain},kube-int-ingress"
    "auth.${domain},kube-int-ingress"
    "longhorn.int.${domain},kube-int-ingress"
  ];
  addresses = [
    "/.int.christianbingman.com/10.2.0.41"
  ];
in {
  sops.defaultSopsFile = ../../secrets/wolverine.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.ts-authkey = {};
  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;

    # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
    # By default, not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.${wan_interface}.accept_ra" = 2;
    "net.ipv6.conf.${wan_interface}.autoconf" = 1;

    "net.ipv6.conf.${lan_interface}.autoconf" = 0;

  };

  networking = {
    hostName = "${hostname}";
    enableIPv6 = true;
    interfaces."${wan_interface}".useDHCP = true;

    interfaces."${lan_interface}" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          prefixLength = 24;
          address = "${lan_ip}";
        }
      ];
      ipv6.addresses = [
        {
          prefixLength = 64;
          address = "${lan_ipv6}";
        }
      ];
    };

    firewall = {
      enable = true;
      allowPing = true;
      # Remove this line
      interfaces.eth0.allowedTCPPorts = [ 22 ];
      interfaces.eth1.allowedTCPPorts = [ 22 53 9162 19999 61208 ];
      interfaces.eth1.allowedUDPPorts = [ 67 68 53 546 547 ];
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o ${wan_interface} -j MASQUERADE
        iptables -A FORWARD -i ${wan_interface} -o ${lan_interface} -m conntrack --ctstate RELATED,ESTABLISHED
        iptables -A FORWARD -i ${lan_interface} -o ${wan_interface}

        ip6tables -t nat -A POSTROUTING -o ${wan_interface} -j MASQUERADE
        ip6tables -A FORWARD -i ${wan_interface} -o ${lan_interface}
        ip6tables -A FORWARD -i ${lan_interface} -o ${wan_interface}
        '';
    };

  };

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "${lan_interface}";
      dhcp-range = dhcp_ranges;
      server = dns_servers;
      no-resolv = true;
      enable-ra = true;
      bind-interfaces = true;
      dhcp-authoritative = true;
      no-hosts = true;
      addn-hosts = [
        "${hosts}"
      ];
      dhcp-lease-max = 100;
      domain = "${domain}";
      expand-hosts = true;
      cache-size = 150;
      dhcp-option = [
        "option6:dns-server,[${lan_ipv6}]"
        "option:dns-server,${lan_ip}"
      ];
      cname = cnames;
      address = addresses;
    };
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--advertise-routes=10.2.0.0/24"
      "--accept-dns=false"
    ];
    authKeyFile = config.sops.secrets.ts-authkey.path;
    useRoutingFeatures = "server";
  };

  services.apcupsd.enable = true;
  services.prometheus.exporters.apcupsd.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;

}
