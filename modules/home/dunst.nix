{ pkgs, ... }:
{
  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      monitor = 0;
      follow = "mouse";

      width = 360;
      height = 300;
      origin = "top-right";
      offset = "16x48";

      notification_limit = 5;

      progress_bar = true;
      progress_bar_height = 8;
      progress_bar_frame_width = 0;
      progress_bar_min_width = 150;
      progress_bar_max_width = 300;

      indicate_hidden = true;
      transparency = 8;
      separator_height = 8;
      padding = 14;
      horizontal_padding = 16;
      text_icon_padding = 12;

      frame_width = 2;
      frame_color = "#89b4fa";

      corner_radius = 12;
      gap_size = 10;

      font = "Hasklig 10";
      line_height = 4;

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
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      frame_color = "#45475a";
      timeout = 4;
    };

    urgency_normal = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      frame_color = "#89b4fa";
      timeout = 6;
    };

    urgency_critical = {
      background = "#1e1e2e";
      foreground = "#f38ba8";
      frame_color = "#f38ba8";
      timeout = 0;
    };
  };
}
