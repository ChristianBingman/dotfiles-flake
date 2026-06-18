{ lib
, writeShellApplication
, findutils
, gnugrep
, gawk
, gnused
, coreutils
, rofi
, pass
, wl-clipboard
, libnotify
}:

let
  passWithOtp = pass.withExtensions (exts: [ exts.pass-otp ]);
in

writeShellApplication {
  name = "rofi-pass";

  runtimeInputs = [
    findutils
    gnugrep
    gawk
    gnused
    coreutils
    rofi
    wl-clipboard
    libnotify
    passWithOtp
  ];

  text = ''
    set -euo pipefail

    PASS_BIN="${passWithOtp}/bin/pass"
    STORE_DIR="''${PASSWORD_STORE_DIR:-$HOME/.password-store}"

    notify() {
      notify-send "pass" "$1"
    }

    if [ ! -d "$STORE_DIR" ]; then
      notify "Password store not found: $STORE_DIR"
      exit 1
    fi

    QUERY="''${1:-}"

    ENTRY="$(
      find "$STORE_DIR" -type f -name '*.gpg' \
        | sed "s|^$STORE_DIR/||; s|\.gpg$||" \
        | grep -i -- "$QUERY" \
        | awk '{ print length(), $0 }' \
        | sort -n \
        | cut -d' ' -f2- \
        | rofi -dmenu -i -p "pass"
    )"

    if [ -z "$ENTRY" ]; then
      notify "No password selected"
      exit 0
    fi

    ACTION="$(
      printf '%s\n%s\n' "Copy password" "Copy OTP" \
        | rofi -dmenu -i -p "$ENTRY"
    )"

    case "$ACTION" in
      "Copy password")
        if "$PASS_BIN" -c "$ENTRY" >/dev/null 2>&1; then
          notify "$ENTRY copied"
        else
          notify "Unable to copy password: $ENTRY"
          exit 1
        fi
        ;;

      "Copy OTP")
        if "$PASS_BIN" otp -c "$ENTRY" >/dev/null 2>&1; then
          notify "$ENTRY OTP copied"
        else
          notify "Unable to copy OTP: $ENTRY"
          exit 1
        fi
        ;;

      *)
        notify "Cancelled"
        exit 0
        ;;
    esac
  '';

  meta = {
    description = "Rofi password-store launcher with OTP support for Wayland/Hyprland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "rofi-pass";
  };
}
