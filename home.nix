{ pkgs, lib, vars, inputs, ... }:
let
  gdmStartHyprland = pkgs.writeShellScriptBin "gdm-start-hyprland" ''
    export PATH="${vars.homedir}/.nix-profile/bin:${vars.homedir}/nix/profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

    export XDG_DATA_DIRS="${vars.homedir}/.nix-profile/share:${vars.homedir}/.local/state/nix/profile/share:/nix/var/nix/profiles/default/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

    exec "${vars.homedir}/.nix-profile/bin/start-hyprland"
  '';
in
{

  imports = [
    inputs.zen-browser.homeModules.beta
    ./modules/home/dunst.nix
    ./modules/home/hyprland.nix
    ./modules/home/tmux.nix
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };
  programs.home-manager.enable = true;
  home.username = vars.username;
  home.homeDirectory = vars.homedir;

  home.stateVersion = "25.11";

  #gtk = lib.mkIf (!pkgs.stdenv.isDarwin) {
  #  enable = true;
  #};

  xdg.configFile.nvim = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    settings.user.name = vars.gituser;
    settings.user.email = vars.gitemail;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh.enable = true;

    initContent = ''
      export PATH="${vars.homedir}/.local/usr/bin:$PATH"
      eval $(gpg-agent --daemon 2> /dev/null)
    '' + lib.optionalString (!vars.meraki or true) ''
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      GPG_TTY=$(tty)
      export GPG_TTY
      if [ -f "${vars.homedir}/.gpg-agent-info" ]; then
          . "${vars.homedir}/.gpg-agent-info"
          export GPG_AGENT_INFO
      fi
    '' + lib.optionalString pkgs.stdenv.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '' + lib.optionalString (vars.meraki or false) ''
      export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:${vars.homedir}/node/bin:$PATH"
    '';

    plugins = [
      {
        name = "syntax-highlighting";
  src = pkgs.zsh-syntax-highlighting;
  file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "powerlevel10k";
  src = pkgs.zsh-powerlevel10k;
  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
  src = pkgs.lib.cleanSource ./config/p10k-config;
  file = "p10k.zsh";
      }
    ];
      
  };

  home.file.".local/share/nvim/site/autoload/plug.vim" = {
    source = "${pkgs.vimPlugins.vim-plug}/plug.vim";
  };

  home.file.".config/.raycast/pass.sh" = {
    source = pkgs.writeShellScript "pass.sh" ''
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title pass
      # @raycast.mode silent

      # Optional parameters:
      # @raycast.icon 🔐
      # @raycast.argument1 { "type": "text", "placeholder": "Path" }
      # @raycast.argument2 { "type": "text", "placeholder": "Copy OTP", "optional": true }

      FINDPASS="$(find $HOME/.password-store -type f | grep "$1" | awk '{ print length(), $0 | "sort -n" }' | sed 's/.*\.password-store\///'| sed 's/\.gpg$//' | head -n1)"

      if [ -z $FINDPASS ]
      then
        echo "No Password Found!"
        exit 0
      fi

      if [ -z "$2" ]; then
        if ${pkgs.pass}/bin/pass -c $FINDPASS 2> /dev/null
        then
          echo "$FINDPASS Copied"
        else
          echo "Unable to find: $FINDPASS"
        fi
      else
        if ${pkgs.pass}/bin/pass otp -c $FINDPASS 2> /dev/null
        then
          echo "$FINDPASS OTP Copied"
        else
          echo "$FINDPASS not found!"
        fi
      fi
    '';
  };

  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      pinentry-program ${pkgs.pinentry-rofi}/bin/pinentry-rofi
      default-cache-ttl 600
      max-cache-ttl 7200
    '' + lib.optionalString (!vars.meraki or true) ''
      enable-ssh-support
    '';
  };

  home.file.".amethyst.yml" = {
    source = pkgs.lib.cleanSource ./config/amethyst/amethyst.yml;
  };

  home.file.".aerospace.toml" = {
    source = pkgs.lib.cleanSource ./config/aerospace/aerospace.toml;
  };

  home.file.".config/ghostty/config" = {
    source = pkgs.lib.cleanSource ./config/ghostty/config;
  };

  home.file.".config/hypr/hyprpaper.conf" = {
    source = pkgs.lib.cleanSource ./config/hypr/hyprpaper.conf;
  };

  home.file.".config/hypr/hypridle.conf" = {
    source = pkgs.lib.cleanSource ./config/hypr/hypridle.conf;
  };

  home.file.".swaylock/config" = {
    source = pkgs.lib.cleanSource ./config/swaylock/config;
  };

  home.file."Background.jpg" = {
    source = pkgs.lib.cleanSource ./config/Background.jpg;
  };

  
  targets.genericLinux = {
    enable = true;
    gpu = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget
    jq
    ripgrep
    gnupg
    hasklig
    ghostty
    (pass.withExtensions (ext: with ext; [pass-otp]))

  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    m-cli # useful macOS CLI commands
    aerospace
  ] ++ lib.optionals (vars.meraki or false) [
    teleport
    nodejs_24
    ollama
    slack
    hyprcursor
    obsidian
    gdmStartHyprland
    wl-clipboard
    codex
    hypridle
    brightnessctl
    kubectl
    krew
    papirus-icon-theme
  ] ++ lib.optionals (!(vars.meraki or false) && !pkgs.stdenv.isDarwin) [
    hyprcursor
    gamescope
    obsidian
    gnucash
  ];
}
