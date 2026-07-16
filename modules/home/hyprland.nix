{ pkgs, lib, ... }:
let
  pass-rofi = pkgs.callPackage ../pass-rofi {};
in
{
  xdg.portal.configPackages = [ pkgs.xdg-desktop-portal-hyprland ];

  home.pointerCursor = lib.mkIf (!pkgs.stdenv.isDarwin) {
    package = pkgs.whitesur-cursors;
    name = "WhiteSur-cursors";
    size = 24;
  };

  home.sessionVariables = lib.mkIf (!pkgs.stdenv.isDarwin) {
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "24";
  };

  wayland.windowManager.hyprland = {
    enable = !pkgs.stdenv.isDarwin;
    settings = {
      "$mainMod" = "CTRL + ALT";
      env = [
        "XCURSOR_THEME,WhiteSur-cursors"
        "XCURSOR_SIZE,24"
      ];
      exec-once = [
        "${pkgs.hyprpaper}/bin/hyprpaper"
        "${pkgs.nwg-look}/bin/nwg-look -a"
        "${pkgs.hypridle}/bin/hypridle"
        "${pkgs.waybar}/bin/waybar"
        "gsettings set org.gnome.desktop.interface color-scheme \"prefer-dark\""
        "gsettings set org.gnome.desktop.interface gtk-theme \"adw-gtk3\""
      ];
      general = {
        "gaps_out" = "5";
        "layout" = "master";
      };
      monitor = [
        "eDP-1,2880x1800@120,0x0,1.5,bitdepth,10"
        "desc:Lenovo Group Limited P34WD-40 V30F63PD, 3440x1440@120, -760x-1440, 1"
      ];
      workspace = [
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          let
            ws = i + 1;
          in
          [
            "${toString ws}, monitor:DP-1"
          ]
        ) 6)
      ) ++ (
        builtins.concatLists (builtins.genList (i:
          let
            ws = i + 7;
          in
          [
            "${toString ws}, monitor:eDP-1"
          ]
        ) 3)
      );
      input = {
        "kb_layout" = "us";
        "kb_variant" = "";
        "kb_options" = "caps:escape";
        "touchpad" = {
          "natural_scroll" = true;
          "scroll_factor" = 0.5;
          "clickfinger_behavior" = true;
          "tap-to-click" = false;
        };
        "resolve_binds_by_sym" = 1;
      };
      device = [
        {
          "name" = "at-translated-set-2-keyboard";
          "kb_layout" = "us";
          "kb_variant" = "colemak_dh_ortho";
        }
      ];
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
        "$mainMod SHIFT, Q, exit"
        "$mainMod, E, resizeactive, 20 0"
        "$mainMod, N, resizeactive, -20 0"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      gesture = [
        "3, horizontal, workspace"
      ];
      bind = [
        "$mainMod, B, exec, zen-beta"
        "$mainMod, T, exec, ${pkgs.ghostty}/bin/ghostty"
        "SUPER, P, exec, ${pass-rofi}/bin/rofi-pass"
        "SUPER, code:65, exec, ${pkgs.rofi}/bin/rofi -show drun"

        "$mainMod, M, layoutmsg, cycleprev"
        "$mainMod, I, layoutmsg, cyclenext"
        "$mainMod, O, layoutmsg, swapwithmaster"

        "CTRL+ALT+SHIFT, A, layoutmsg, addmaster"
        "CTRL+ALT+SHIFT, S, layoutmsg, removemaster"

        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
        ", Print, exec, ${pkgs.bash}/bin/bash -lc \"${pkgs.grim}/bin/grim -o \\\"$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')\\\" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png && ${pkgs.libnotify}/bin/notify-send 'Screenshot captured' 'Focused monitor copied to clipboard'\""
        "SHIFT, Print, exec, ${pkgs.bash}/bin/bash -lc \"${pkgs.grim}/bin/grim -g \\\"$(${pkgs.slurp}/bin/slurp)\\\" - | ${pkgs.wl-clipboard}/bin/wl-copy --type image/png && ${pkgs.libnotify}/bin/notify-send 'Screenshot captured' 'Selection copied to clipboard'\""

        "$mainMod, Y, workspace, +1"
        "$mainMod, L, workspace, -1"

        "$mainMod, Z, layoutmsg, orientationleft"
        "$mainMod, X, layoutmsg, orientationcenter"
        "$mainMod, C, layoutmsg, orientationright"

        "SUPER, F, fullscreen, 1"
        "$mainMod, F, togglefloating,"
        "SUPER, W, killactive"
        "SUPER, Q, forcekillactive"
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          let
            ws = i + 1;
          in
          [
            "$mainMod, code:1${toString i}, workspace, ${toString ws}"
            "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9)
      );
      windowrule = [
        {
          name = "steam-game";
          "match:class" = "^(steam_app.*)";
          opaque = "on";
        }
        {
          name = "slack";
          "match:class" = "^Slack$";
          workspace = 2;
        }
        {
          name = "webex";
          "match:class" = "^webex$";
          workspace = 2;
        }
        {
          name = "Cisco Secure Client";
          "match:class" = "^com.cisco.secureclient.gui$";
          workspace = 7;
        }
      ];
    };
  };
}
