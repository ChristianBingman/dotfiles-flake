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
  system.primaryUser = "christianbingman";

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
        name = "raycast";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "gnucash";
        args = { appdir = "~/applications"; };
      }
      {
        name = "anki";
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
    ];
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      meh - t : open ~/Applications/kitty.app
      meh - b : open https://search.int.christianbingman.com
    '';
  };

  users.users.christianbingman.home = vars.homedir;
  environment.systemPackages = with pkgs; [
    (pass.withExtensions (ext: with ext; [pass-otp]))
  ];
}
