{ pkgs, lib, vars, ... }:
{
  programs.home-manager.enable = true;
  home.username = vars.username;
  home.homeDirectory = vars.homedir;

  home.stateVersion = "24.05";

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "CTRL + ALT";
    exec-once = [
      "${pkgs.hyprpaper}/bin/hyprpaper"
      "${pkgs.nwg-look}/bin/nwg-look -a"
    ];
    general = {
      "gaps_out" = "5";
      "layout" = "master";
    };
    decoration = {
      "rounding" = "10";
      "inactive_opacity" = "0.75";
      "fullscreen_opacity" = "0.95";
      blur = {
        "xray" = "true";
      };
    };
    cursor = {
      "inactive_timeout" = "10";
      "persistent_warps" = "true";
      "hide_on_key_press" = "true";
    };
    ecosystem = {
      "no_donation_nag" = "true";
    };
    binde = [
      "$mainMod, N, resizeactive, 10 0"
      "$mainMod, E, resizeactive, -10 0"
    ];
    bind = [
      "$mainMod, B, exec, ${pkgs.firefox}/bin/firefox"
      "$mainMod, T, exec, ${pkgs.ghostty}/bin/ghostty"
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"

      "$mainMod, M, layoutmsg, cycleprev"
      "$mainMod, I, layoutmsg, cyclenext"
      "$mainMod, O, layoutmsg, swapwithmaster"
      "$mainMod, F, fullscreen, 1"
      "SUPER, W, killactive"
      "SUPER, Q, forcekillactive"
      "SUPER, code:65, exec, ${pkgs.rofi}/bin/rofi -show drun"
    ] ++ (
      # workspaces
      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mainMod, code:1${toString i}, workspace, ${toString ws}"
            "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        )
        9)
    );
    #submaps = {
    #  resize = {
    #    settings = {
    #      binde = [
    #        
    #      ];
    #      bind = [
    #        ", escape, submap, reset"
    #      ];
    #    };
    #  };
    #};
    monitor = [
      "HDMI-A-1, disable"
      "HDMI-A-2,2560x1600@60,auto,auto"
    ];
  };

  xdg.configFile.nvim = {
    source = ./config/nvim;
    recursive = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

    extraConfig = ''
      # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"
      set-option -g status-position top
      set-option -g default-command ${pkgs.zsh}/bin/zsh

      # Mouse works as expected
      set-option -g mouse on
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind -r C-e resize-pane -U
      bind -r C-n resize-pane -D
      bind -r C-m resize-pane -L
      bind -r C-i resize-pane -R
      bind -r e select-pane -U
      bind -r n select-pane -D
      bind -r m select-pane -L
      bind -r i select-pane -R
      unbind Up     
      unbind Down   
      unbind Left   
      unbind Right  
      unbind C-Up   
      unbind C-Down 
      unbind C-Left 
      unbind C-Right
      
      ## COLORSCHEME: everforest dark medium
      set-option -g status "on"
      set -g status-interval 2

      set-option -g status-fg 'color181' # fg
      set-option -g status-bg 'color236' # bg0

      set-option -g mode-style fg='color175',bg='color238' # fg=purple, bg=bg_visual

      # default statusbar colors
      set-option -g status-style fg='color181',bg='color235',default # fg=fg bg=bg_dim

      # ---- Windows ----
      # default window title colors
      set-window-option -g window-status-style fg='color59',bg='color236' # fg=yellow bg=bg0

      # default window with an activity alert
      set-window-option -g window-status-activity-style bg=colour237,fg=colour248 # bg=bg1, fg=fg3

      # active window title colors
      set-window-option -g window-status-current-style fg='color181',bg='color238' # fg=fg bg=bg_green

      # ---- Pane ----
      # pane borders
      set-option -g pane-border-style fg='color237' # fg=bg1
      set-option -g pane-active-border-style fg='color109' # fg=blue

      # pane number display
      set-option -g display-panes-active-colour 'color109' # blue
      set-option -g display-panes-colour 'color174' # orange

      # ---- Command ----
      # message info
      set-option -g message-style fg='color174',bg='color235' # fg=statusline3 bg=bg_dim

      # writing commands inactive
      set-option -g message-command-style fg='colour223',bg='colour239' # bg=fg3, fg=bg1

      # ---- Miscellaneous ----
      # clock
      set-window-option -g clock-mode-colour 'color109' #blue

      # bell
      set-window-option -g window-status-bell-style fg='color236',bg='color174' # fg=bg, bg=statusline3

      # ---- Formatting ----
      set-option -g status-left-style none
      set -g status-left-length 60
      set -g status-left '#[fg=color235,bg=color144,bold] #S #[fg=color144,bg=color238,nobold] #[fg=color144,bg=color238,bold]#(whoami) #[bg=color236] '

      set-option -g status-right-style none
      set -g status-right-length 150
      set -g status-right '#[fg=color238] #[fg=color181,bg=color238] #[fg=color181,bg=color238]%Y-%m-%d | %H:%M #[fg=color235,bg=color108,bold] #h '

      set -g window-status-separator '#[fg=color247,bg=color236] '
      set -g window-status-format "#[fg=color8,bg=color236] #I | #[fg=color8,bg=color236]#W  "
      set -g window-status-current-format "#[fg=color181,bg=color238] #I | #[fg=color181,bg=color238,bold]#W #[fg=color238,bg=color236,nobold] "
    '';
  };

  programs.git = {
    enable = true;
    userName = vars.gituser;
    userEmail = vars.gitemail;
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

    initExtra = ''
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
      pinentry-program /opt/homebrew/bin/pinentry-mac
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

  home.file."Background.jpg" = {
    source = pkgs.lib.cleanSource ./config/Background.jpg;
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
    (pass.withExtensions (ext: with ext; [pass-otp]))

  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
    aerospace
  ] ++ lib.optionals (vars.meraki or false) [
    teleport
  ] ++ lib.optionals (!(vars.meraki or false) && !stdenv.isDarwin) [
    hyprcursor
    gamescope
    obsidian
    gnucash
  ];
}
