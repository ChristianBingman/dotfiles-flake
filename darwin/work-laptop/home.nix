{ pkgs, lib, mac_vars, ... }:
let
  jiracli = pkgs.fetchzip {
    url = "https://github.com/ankitpokhrel/jira-cli/releases/download/v1.4.0/jira_1.4.0_macOS_arm64.tar.gz";
    hash = "sha256-7GtIIW1DfFdFbGBu9HMYhRlxDsbhdV41xe9rm2GxM7Q=";
  };
in
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
    userName = "ChristianBingman";
    userEmail = "chrsitianbingman@gmail.com";
  };

  programs.kitty = {
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
      cursor = "#0DB9D7";
      background = "#1A1B26";
      foreground = "#A9B1D6";
      color0 = "#32344A";
      color8 = "#444B6A";
      color1 = "#F7768E";
      color9 = "#FF7A93";
      color2 = "#9ECE6A";
      color10 = "#B9F27C";
      color3 = "#E0AF68";
      color11 = "#FF9E64";
      color4 = "#7AA2F7";
      color12 = "#7DA6FF";
      color5 = "#AD8EE6";
      color13 = "#BB9AF7";
      color6 = "#449DAB";
      color14 = "#0DB9D7";
      color7 = "#787C99";
      color15 = "#ACB0D0";
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
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
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

  home.file.".local/usr/bin/jira" = {
    source = "${jiracli}/bin/jira";
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
