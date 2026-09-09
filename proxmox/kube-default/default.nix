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
    ln -sfn ${pkgs.cryptsetup}/bin/cryptsetup /bin
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

  virtualisation.containerd.settings = {
    debug.level = "warn";
    plugins."io.containerd.grpc.v1.cri".sandbox_image = "registry.k8s.io/pause:latest";
  };
}
