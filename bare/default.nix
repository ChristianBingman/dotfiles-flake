{ config, lib, pkgs, home-manager, ... }:
let
  filebeat_config = builtins.toJSON {
    filebeat = {
      inputs = [
        {
          type = "journald";
          id = "everything";
        }
      ];
    };
    logging = {
      level = "warning";
    };
    output = {
      logstash = {
        hosts = [ "logstash.christianbingman.com:5044" ];
      };
    };
  };
  vars = {
    username = "christian";
    homedir = "/home/christian";
    gituser = "ChristianBingman";
    gitemail = "christianbingman@gmail.com";
  };
in{
  home-manager.users.christian = import ../home.nix { inherit pkgs lib vars; };
    
  networking = {
    usePredictableInterfaceNames = false;
  };

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  programs.zsh.enable = true;
  users.users.christian = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [ "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "password";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCtje1dqWaFyxnmIuQUB40arQ2FHAMD79n28zxzvFrDglxPgdYenqUXemBr07lqGDyHU7baYk+2RO9jg9mq0/F5MA89FkuK0u2YI0wY1fH4JAs+T6S0guOpvfL4MFulbSoxs9EFeBaZ2hQ/GCUjyTQwmyXFffVWWOTjULo8MIdg3ph03JHK50ehnFFu3ESRwoXLlG6g+x4FEWoZg21gSGLsgsWKxsX7VO55Vs0ko/+Qo7tFYi/hGfX+zHZ4NfDn3yGxD9sKMuet+Z823kKDIiA9wbALy+/LbS/2qags3wSAmiMvHNIE1M04otfd6kOfUPi86lyVWpcKHE3nT1NvCDdNvpXy/u97K/HeguA9bRuIFZKqvSz0xaNlKMGGTTTtKj2VxxnDi57SG5QLZMx+N5BViPNsE3e9ZQCmhlwzR2kGFas02c1HE1e4c2pXytLTIeGvrL75GDO/SF8N3WtC9uIWn4nH9iDEzIM48OwJHT4UqiNCz62t8KEpeoPwVaxNOZn0hEnNvpKPlj//HW2XnGh/FWyN6Nl7dM+GXiS89E8BMU4G1sN5RxPGA/Q2OuwKT5KXBTRQfbxHpJVy+r7J72F6C68Cc2k7keim+DTSpDrz1EjKA7SX0gxBWmsjsFZedupQWnapgMarMrT2NTCgpFSIDIaFdxW+HRPaPdOUbfQTnw== christianbingman@MacBook-Pro.local" ];
  };

  users.users.nixos = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEYaLR9ZF6cbwDKaZNbhBfMSRCRm/yCsnLp59BJoXG9W christian@humantorch" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "nixos" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.pathsToLink = [ "/share/zsh" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?


  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings.trusted-users = [ "root" "nixos" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services.netdata.enable = true;
  services.netdata.config.statsd.enabled = "yes";
  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  services.filebeat.enable = lib.mkDefault true;

  systemd.services.filebeat.serviceConfig.ExecStart = lib.mkForce ''
    ${pkgs.filebeat}/bin/filebeat -e \
      -c '${pkgs.writeText "filebeat.json" filebeat_config}' \
      --path.data '/var/lib/filebeat'
  '';
}
