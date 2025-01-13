{ config, lib, pkgs, ... }:
let
  kubeMasterHostname = "kube-master-int";
  kubeMasterAPIServerPort = 6443;
  caFile = "/var/lib/kubernetes/secrets/ca.pem";
  certmgrPatch = pkgs.writeTextFile {
    name = "disable-kube-dns-check.patch";
    text = builtins.readFile ../../patches/disable-kube-dns-check.patch;
  };
  certmgr = pkgs.certmgr.overrideAttrs (old: { patches = [ "${certmgrPatch}" ]; });
  api = "https://${kubeMasterHostname}:6443";
in {
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets."elasticsearch_pass" = {sopsFile = ../../secrets/kube-shared.yaml;};
  sops.templates."elasticsearch_config.json".content = builtins.toJSON {
    filebeat = {
      inputs = [
        {
          type = "container";
          paths = [
            "/var/log/containers/*.log"
          ];
        }
      ];
    };
    processors = [
      {
        dissect = {
          tokenizer = "/var/log/containers/%{orchestrator.resource.name}_%{orchestrator.resource.namespace}_%{orchestrator.resource.id}.log";
          field = "log.file.path";
          target_prefix = "";
        };
      }
    ];
    logging = {
      level = "info";
    };
    output = {
      elasticsearch = {
        hosts = [ "elasticsearch-int.christianbingman.com:9200" ];
        username = "elastic";
        password = config.sops.placeholder."elasticsearch_pass";
      };
    };
    setup.ilm = {
      enabled = true;
      rollover_alias = "kubernetes-%{[agent.version]}";
      pattern = "{now/d}-000001";
      policy_name = "kubernetes-30d";
    };
  };
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
    autoResize = true;
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "ext4";
  };
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 2379 2380 6443 7946 8888 9100 10250 10256 10257 10259 19999 ];

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes
    nfs-utils
    cifs-utils
  ];

  # For longhorn
  services.openiscsi.enable = true;
  services.openiscsi.name = "iqn.2016-04.com.open-iscsi:af916e8564";
  system.activationScripts.longhorn.text = ''
    ln -sfn ${pkgs.openiscsi}/bin/iscsiadm /bin
    ln -sfn ${pkgs.util-linux}/bin/mount /bin
    ln -sfn ${pkgs.util-linux}/bin/fstrim /bin
  '';

  services.kubernetes = {
    masterAddress = kubeMasterHostname;
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      allowPrivileged = true;
      extraOpts = ''
        --requestheader-client-ca-file=${caFile} \
        --requestheader-allowed-names=front-proxy-client \
        --requestheader-extra-headers-prefix=X-Remote-Extra- \
        --requestheader-group-headers=X-Remote-Group \
        --requestheader-username-headers=X-Remote-User
      '';
      extraSANs = [ "kube-master-int" "kube-master-int.christianbingman.com" ];
    };
    pki.cfsslAPIExtraSANs = [ "kube-master-int" "kube-master-int.christianbingman.com" ];

    kubelet.kubeconfig.server = api;
    apiserverAddress = api;

    # use coredns
    addons.dns.enable = true;
    flannel.enable = true;
  };

  services.certmgr.package = lib.mkForce certmgr;

  systemd.services.filebeat-container = {
    serviceConfig.ExecStart = ''
      ${pkgs.filebeat}/bin/filebeat -e \
        -c '${config.sops.templates."elasticsearch_config.json".path}' \
        --path.data '/var/lib/filebeat-container'
    '';
    serviceConfig.ExecStartPre = pkgs.writeShellScript "filebeat-container-pre" ''
      set -euo pipefail

      umask u=rwx,g=,o=

      if [[ -h '/var/lib/filebeat/filebeat.yml' ]]; then
        rm '/var/lib/filebeat/filebeat.yml'
      fi

      inherit_errexit_enabled=0
      shopt -pq inherit_errexit && inherit_errexit_enabled=1
      shopt -s inherit_errexit

      ${pkgs.jq}/bin/jq >'/var/lib/filebeat/filebeat.yml' . <<'EOF'
      {"filebeat":{"inputs":[],"modules":[]},"output":{"elasticsearch":{"hosts":["127.0.0.1:9200"]}}}
      EOF
      (( ! $inherit_errexit_enabled )) && shopt -u inherit_errexit
    '';
    serviceConfig.Restart = "always";
    serviceConfig.StateDirectory = "filebeat-container";
    wantedBy = [ "multi-user.target" ];
  };
}
