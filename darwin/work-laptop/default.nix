{ config, pkgs, lib, mac_vars, ... }:
{

  home-manager.users.cbingman = import ./home.nix { inherit pkgs lib mac_vars; };

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
        name = "amethyst";
        args = { appdir = "~/Applications"; };
      }
      {
        name = "raycast";
        args = { appdir = "~/Applications"; };
      }
    ];
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  services.skhd = {
    enable = true;
    skhdConfig = ''
      meh - t : open ${pkgs.kitty}/Applications/kitty.app
      meh - b : open https://meraki.okta.com
    '';
  };

  users.users.cbingman.home = "/Users/cbingman";


  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    openssh
  #  kitty
  #  terminal-notifier
  ];

  # https://github.com/nix-community/home-manager/issues/423
  #environment.variables = {
  #  TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  #};
  #programs.nix-index.enable = true;

  # Fonts
  #fonts.enableFontDir = true;
  #fonts.fonts = with pkgs; [
  #   recursive
  #   (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  # ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyle = "Dark";
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    "com.apple.mouse.tapBehavior" = 1;
    "com.apple.sound.beep.feedback" = 0;
    NSDocumentSaveNewDocumentsToCloud = true;
  };

  system.defaults.dock = {
    autohide = true;
  };

  system.defaults.finder = {
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    CreateDesktop = false;
  };

  system.defaults.trackpad.TrackpadRightClick = true;

  time.timeZone = "America/Los_Angeles";

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    /usr/bin/automator -i ${pkgs.lib.cleanSource ../../config/Background.jpg} ${pkgs.lib.cleanSource ../../config/setDesktopPicture.workflow}
  '';

  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      AppleHighlightColor = "1.000000 0.874510 0.701961 Orange";
      AppleAccentColor = 1;
    };
    "com.apple.finder" = {
      FXDefaultSearchScope = "SCcf";
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.Safari" = {
      AutoOpenSafeDownloads = false;
      WebAutomaticSpellingCorrectionEnabled = false;
      ShowFullURLInSmartSearchField = true;
      AutoFillFromAddressBook = false;
      AutoFillCreditCardData = false;
      AutoFillMiscellaneousForms = false;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.commerce".AutoUpdate = true;
  };

  fonts.packages = [ pkgs.hasklig ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
      system = ${pkgs.system}
    '';
    settings.trusted-users = [ "root" "nixos" "@admin"];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    settings.substituters = [
      "https://cache.nixos.org/"
    ];

    configureBuildUsers = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

  };

}
