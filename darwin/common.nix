{ config, pkgs, lib, ... }:
{
  system.stateVersion = 5;
  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    openssh
  ];

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
  #  static-only = true;
  };

  system.defaults.finder = {
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    CreateDesktop = false;
  };

  system.defaults.trackpad.TrackpadRightClick = true;

  time.timeZone = lib.mkDefault "America/Chicago";

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  #system.activationScripts.postUserActivation.text = ''
  #  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  #  /usr/bin/automator -i ${pkgs.lib.cleanSource ../config/Background.jpg} ${pkgs.lib.cleanSource ../config/setDesktopPicture.workflow}
  #'';
  

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
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "79" = {
          enabled = true;
          value = {
            parameters = [ 108 37 917504 ];
            type = "standard";
          };
        };
        "81" = {
          enabled = true;
          value = {
            parameters = [ 121 16 917504 ];
            type = "standard";
          };
        };
        "64" = {
          enabled = false;
        };
        "65" = {
          enabled = false;
        };
      };
    };
  };

  fonts.packages = [ pkgs.hasklig ];

  nix = {
    enable = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = [
      "@admin"
    ];
  };

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
    system = ${pkgs.system}
  '';

}
