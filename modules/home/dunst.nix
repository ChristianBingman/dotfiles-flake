{ config, pkgs, lib, ... }:
let
  iconPath = lib.concatStringsSep ":" [
    "${config.home.homeDirectory}/.nix-profile/share/icons"
    "${config.home.homeDirectory}/.local/share/icons"
    "/run/current-system/sw/share/icons"
    "/run/current-system/sw/share/pixmaps"
    "/usr/local/share/icons"
    "/usr/share/icons"
    "/usr/share/pixmaps"
    "/var/lib/snapd/desktop/icons"
  ];
in
{
  services.dunst = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";

        width = 360;
        height = 300;
        origin = "top-right";
        offset = "12x42";

        notification_limit = 5;

        progress_bar = true;
        progress_bar_height = 8;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;

        indicate_hidden = true;
        transparency = 0;
        separator_height = 6;
        padding = 12;
        horizontal_padding = 14;
        text_icon_padding = 12;

        frame_width = 1;
        frame_color = "#a7c080";

        separator_color = "frame";
        corner_radius = 12;
        gap_size = 8;

        font = "Hasklug Nerd Font 11";
        line_height = 3;

        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";

        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;

        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 48;
        icon_path = iconPath;

        sticky_history = true;
        history_length = 20;

        browser = "${pkgs.xdg-utils}/bin/xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        ignore_dbusclose = false;
        force_xinerama = false;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      experimental = {
        per_monitor_dpi = false;
      };

      urgency_low = {
        background = "#343c3d";
        foreground = "#d3c6aa";
        frame_color = "#494d64";
        highlight = "#494d64";
        timeout = 4;
      };

      urgency_normal = {
        background = "#282c34";
        foreground = "#d3c6aa";
        frame_color = "#a7c080";
        highlight = "#a7c080";
        timeout = 6;
      };

      urgency_critical = {
        background = "#282c34";
        foreground = "#e67e80";
        frame_color = "#e67e80";
        highlight = "#e67e80";
        timeout = 0;
      };
    };
  };
}
