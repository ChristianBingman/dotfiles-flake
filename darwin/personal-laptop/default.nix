{ config, pkgs, lib, ... }:
let
vars = {
  username = "christianbingman";
  homedir = "/Users/christianbingman";
  gituser = "ChristianBingman";
  gitemail = "christianbingman@gmail.com";
};
in{
  home-manager.users.christianbingman = import ../../home.nix { inherit pkgs lib vars; };

  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    brews = [
      "pinentry-mac"
    ];
    casks = [
      {
        name = "amethyst";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "raycast";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "gnucash";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "openscad";
        args = { appdir = "~/Applications"; };
      }
    ];
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      meh - t : open ${pkgs.kitty}/Applications/kitty.app
      meh - b : open https://www.google.com
      meh - g : /Applications/Steam\ Link.app/Contents/MacOS/Steam\ Link --windowed
    '';
  };

  users.users.christianbingman.home = vars.homedir;
}
