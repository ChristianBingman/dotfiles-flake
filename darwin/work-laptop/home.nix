{ pkgs, lib, mac_vars, ... }:
{
  programs.home-manager.enable = true;
  home.username = "cbingman";
  home.homeDirectory = "/Users/cbingman";

  home.stateVersion = "24.05";
  

  xdg.configFile.nvim = {
    source = ../../config/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    userName = "christia";
    userEmail = "christian.bingman@meraki.net";
  };

  programs.kitty = if pkgs.stdenv.isDarwin then {
    enable = true;
    font = {
      name = "Hasklig";
      package = pkgs.hasklig;
      size = 20.0;
    };
    settings = {
      scrollback_lines = 2000;
      copy_on_select = "clipboard";
      enable_audio_bell = "no";
      remember_window_size = "yes";
      enabled_layouts = "tall:bias=70,vertical";
      hide_window_decorations = "titlebar-only";
      tab_bar_style = "hidden";
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/mykitty";
      background_opacity = "0.9";
      clear_all_shortcuts = "yes";
      kitty_mod = "cmd";
      # Colorscheme
      foreground = "#d3c6aa";
      background = "#272e33";
      selection_foreground = "#9da9a0";
      selection_background = "#464e53";
      cursor = "#d3c6aa";
      cursor_text_color = "#2e383c";
      url_color = "#7fbbb3";
      active_border_color = "#a7c080";
      inactive_border_color = "#4f5b58";
      bell_border_color = "#e69875";
      visual_bell_color = "none";
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";
      active_tab_background = "#272e33";
      active_tab_foreground = "#d3c6aa";
      inactive_tab_background = "#374145";
      inactive_tab_foreground = "#9da9a0";
      tab_bar_background = "#2e383c";
      tab_bar_margin_color = "none";
      mark1_foreground = "#272e33";
      mark1_background = "#7fbbb3";
      mark2_foreground = "#272e33";
      mark2_background = "#d3c6aa";
      mark3_foreground = "#272e33";
      mark3_background = "#d699b6";
      color0 = "#343f44";
      color8 = "#868d80";
      color1 = "#e67e80";
      color9 = "#e67e80";
      color2 = "#a7c080";
      color10 = "#a7c080";
      color3 = "#dbbc7f";
      color11 = "#dbbc7f";
      color4 = "#7fbbb3";
      color12 = "#7fbbb3";
      color5 = "#d699b6";
      color13 = "#d699b6";
      color6 = "#83c092";
      color14 = "#83c092";
      color7 = "#859289";
      color15 = "#9da9a0";
    };

    keybindings = {
      "kitty_mod+n" = "launch --location=first --cwd=current";
      "kitty_mod+shift+n" = "launch --location=first";
      "kitty_mod+w" = "close_window";
      "kitty_mod+q" = "quit";
      "ctrl+alt+super+c" = "clear_terminal scroll active";
      "kitty_mod+up" = "scroll_page_up";
      "kitty_mod+down" = "scroll_page_down";
      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      "kitty_mod+escape" = "show_scrollback";

      "kitty_mod+shift+l" = "next_layout";
      "kitty_mod+j" = "previous_window";
      "kitty_mod+k" = "next_window";
      "kitty_mod+i" = "move_window_to_top";
      "kitty_mod+h" = "resize_window narrower";
      "kitty_mod+l" = "resize_window wider";
    };

    shellIntegration.enableZshIntegration = true;
  } else {};

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
      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval $(gpg-agent --daemon 2> /dev/null)
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      GPG_TTY=$(tty)
      export GPG_TTY
      if [ -f "/Users/cbingman/.gpg-agent-info" ]; then
          . "/Users/cbingman/.gpg-agent-info"
          export GPG_AGENT_INFO
      fi
      export PATH="/Users/cbingman/.local/usr/bin:$PATH"
    '';

    plugins = [
      {
        name = "syntax-highlighting";
  src = pkgs.zsh-syntax-highlighting;
  file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "git-prompt";
  src = pkgs.zsh-git-prompt;
      }
      {
        name = "powerlevel10k";
  src = pkgs.zsh-powerlevel10k;
  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
  src = pkgs.lib.cleanSource ../../config/p10k-config;
  file = "p10k.zsh";
      }
    ];

    shellAliases = {
      s = "kitty +kitten ssh";
    };
      
  };

  home.file.".local/share/nvim/site/autoload/plug.vim" = {
    source = "${pkgs.vimPlugins.vim-plug}/plug.vim";
  };

  home.file.".config/.raycast" = {
    source = pkgs.lib.cleanSource ../../config/raycast;
    recursive = true;
  };

  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
      enable-ssh-support
      default-cache-ttl 600
      max-cache-ttl 7200
    '';
  };

  home.file.".amethyst.yml" = {
    source = pkgs.lib.cleanSource ../../config/amethyst/amethyst.yml;
  };

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget
    jq
    ripgrep
    gnupg

  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
  ];
}
