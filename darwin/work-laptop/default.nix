{ config, pkgs, lib, mac_vars, ... }:
let
vars = {
  username = "cbingman";
  homedir = "/Users/cbingman";
  gituser = "christia";
  gitemail = "christian.bingman@meraki.net";
  meraki = true;
};
in 
{
  home-manager.users.cbingman = import ../../home.nix { inherit pkgs lib vars; };

  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    masApps = {
      "Slack for Desktop" = 803453959;
    };
    brews = [
      "pinentry-mac"
    ];
    casks = [
      {
        name = "raycast";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "orion";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "karabiner-elements";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "ghostty";
        args = { appdir = "~/Applications"; };
      }
    ];
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  services.skhd = {
    enable = true;
    skhdConfig = ''
      meh - t : open ~/Applications/ghostty.app
      meh - b : open https://search.christianbingman.com
    '';
  };

  users.users.cbingman.home = vars.homedir;

  time.timeZone = "America/Los_Angeles";
}
