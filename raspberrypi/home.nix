{ pkgs, lib, ... }:
{
  programs.home-manager.enable = true;
  home.username = "christian";
  home.homeDirectory = "/home/christian";

  home.stateVersion = "24.05";
  

  xdg.configFile.nvim = {
    source = ../config/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    userName = "ChristianBingman";
    userEmail = "christianbingman@gmail.com";
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
      eval $(gpg-agent --daemon 2> /dev/null)
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      GPG_TTY=$(tty)
      export GPG_TTY
      if [ -f "/home/christian/.gpg-agent-info" ]; then
          . "/home/christian/.gpg-agent-info"
          export GPG_AGENT_INFO
      fi
      export PATH="/home/christian/.local/usr/bin:$PATH"
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
  src = pkgs.lib.cleanSource ../config/p10k-config;
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

  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
      enable-ssh-support
      default-cache-ttl 600
      max-cache-ttl 7200
    '';
  };

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget
    jq
    ripgrep
    gnupg

  ];
}
