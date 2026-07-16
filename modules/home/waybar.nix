{ pkgs, lib, ... }:
{
  programs.waybar = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 0;
        modules-left = [ ];
        modules-center = [ ];
        modules-right = [ "privacy" "hyprland/workspaces" "wireplumber" "battery" "clock" ];

        "hyprland/workspaces" = {
          format = "󰆍  {name}";
          all-outputs = false;
          active-only = true;
        };

        clock = {
          format = "󰥔  {:%Y-%m-%d | %H:%M}";
          tooltip = false;
        };

        battery = {
          format = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-plugged = "󰚥  {capacity}%";
          format-full = "󰁹  {capacity}%";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip = false;
        };

        wireplumber = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  muted";
          format-icons = [ "󰕿" "󰖀" "󰕾" ];
          tooltip = false;
          scroll-step = 5;
          on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        privacy = {
          icon-spacing = 4;
          icon-size = 14;
          transition-duration = 200;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 20;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 20;
            }
          ];
        };
      }
    ];

    style = ''
      @define-color bg_dim rgba(45, 53, 54, 0.0);
      @define-color bg0 rgba(40, 44, 52, 0.92);
      @define-color bg1 rgba(52, 60, 61, 0.95);
      @define-color bg_visual rgba(73, 77, 100, 0.92);
      @define-color green rgba(167, 192, 128, 0.98);
      @define-color fg rgba(211, 198, 170, 0.98);

      * {
        border: none;
        border-radius: 10px;
        font-family: Hasklug Nerd Font Mono, Hasklug Nerd Font, monospace;
        font-size: 13px;
        font-weight: 600;
        min-height: 0;
      }

      window#waybar {
        background: @bg_dim;
        color: @fg;
      }

      window#waybar > box {
        padding: 6px 10px 0 0;
      }

      #clock,
      #wireplumber,
      #battery,
      #workspaces {
        padding: 2px 10px;
        margin-left: 6px;
        background: @bg_visual;
        color: @fg;
      }

      #workspaces button {
        padding: 2px 10px;
        margin: 0;
        border-radius: 8px;
        background: transparent;
        color: @fg;
      }

      #workspaces button.active {
        background: transparent;
        color: @fg;
      }

      #workspaces button:hover {
        background: transparent;
        color: @fg;
      }

      #clock {
        background: @bg1;
      }

      #battery {
        background: @green;
        color: @bg0;
      }

      #privacy {
        background: transparent;
      }

      #privacy-item {
        padding: 2px 10px;
        margin-left: 6px;
        border-radius: 10px;
        background: @bg1;
        color: @fg;
      }
    '';
  };
}
