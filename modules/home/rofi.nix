{ pkgs, lib, ... }:
let
  rofiTheme = pkgs.writeText "rofi-theme.rasi" ''
    * {
      bg-dim:      rgba(45, 53, 54, 0.92);
      bg0:         rgba(40, 44, 52, 0.96);
      bg1:         rgba(52, 60, 61, 0.96);
      bg-visual:   rgba(73, 77, 100, 0.92);
      green:       rgba(167, 192, 128, 0.98);
      fg:          rgba(211, 198, 170, 0.98);
      fg-muted:    rgba(211, 198, 170, 0.70);
      border:      rgba(167, 192, 128, 0.40);
      font: "Hasklug Nerd Font 13";
    }

    window {
      width: 32em;
      location: center;
      anchor: center;
      x-offset: 0px;
      y-offset: 0px;
      background-color: @bg-dim;
      border: 1px;
      border-color: @border;
      border-radius: 12px;
    }

    mainbox {
      background-color: transparent;
      children: [ "inputbar", "message", "listview" ];
      spacing: 10px;
      padding: 12px;
    }

    inputbar {
      background-color: @bg1;
      border-radius: 10px;
      padding: 8px 10px;
      spacing: 8px;
      children: [ "prompt", "entry" ];
    }

    prompt {
      background-color: transparent;
      text-color: @green;
    }

    entry {
      background-color: transparent;
      text-color: @fg;
      placeholder: "Search";
      placeholder-color: @fg-muted;
    }

    message {
      background-color: transparent;
      text-color: @fg-muted;
    }

    listview {
      background-color: transparent;
      lines: 8;
      columns: 1;
      fixed-height: false;
      dynamic: true;
      scrollbar: false;
      spacing: 6px;
    }

    element {
      background-color: @bg0;
      text-color: @fg;
      border-radius: 10px;
      padding: 8px 10px;
      spacing: 8px;
    }

    element selected {
      background-color: @green;
      text-color: @bg0;
    }

    element-icon {
      size: 1.1em;
      background-color: transparent;
      text-color: inherit;
    }

    element-text {
      background-color: transparent;
      text-color: inherit;
      vertical-align: 0.5;
    }
  '';
in
{
  xdg.configFile."rofi/config.rasi" = lib.mkIf (!pkgs.stdenv.isDarwin) {
    text = ''
      configuration {
        modi: "drun,run,window";
        show-icons: true;
        drun-display-format: "{name}";
        display-drun: "apps";
        display-run: "run";
        display-window: "windows";
        font: "Hasklug Nerd Font 13";
        terminal: "${pkgs.ghostty}/bin/ghostty";
      }

      @theme "${rofiTheme}"
    '';
  };
}
