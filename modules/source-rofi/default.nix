{ lib
, writeShellApplication
, coreutils
, findutils
, gnugrep
, gnused
, rofi
, libnotify
}:

writeShellApplication {
  name = "rofi-obsidian-source";

  runtimeInputs = [
    coreutils
    findutils
    gnugrep
    gnused
    rofi
    libnotify
  ];

  text = ''
    set -euo pipefail

    VAULT_DIR="$HOME/Documents/Meraki-WorkDocs"
    SOURCES_DIR="$VAULT_DIR/04 Sources"
    PROJECTS_DIR="$VAULT_DIR/02 Projects"

    notify() {
      notify-send "Obsidian source" "$1"
    }

    prompt() {
      printf '\n' | rofi -dmenu -i -p "$1"
    }

    yaml_escape() {
      printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
    }

    if [ ! -d "$SOURCES_DIR" ]; then
      notify "Sources directory not found: $SOURCES_DIR"
      exit 1
    fi

    SOURCE_TYPE="$(printf '%s\n' slack web webex | rofi -dmenu -i -p "Type")"
    case "$SOURCE_TYPE" in
      slack|web|webex) ;;
      *)
        notify "Cancelled"
        exit 0
        ;;
    esac

    URL="$(prompt "URL")"
    if [ -z "$URL" ]; then
      notify "A URL is required"
      exit 0
    fi

    TITLE="$(prompt "Source title")"
    if [ -z "$TITLE" ]; then
      notify "A source title is required"
      exit 0
    fi
    if printf '%s' "$TITLE" | grep -q '/'; then
      notify "Source titles cannot contain /"
      exit 1
    fi

    if [ -d "$PROJECTS_DIR" ]; then
      PROJECT="$(
        {
          printf '%s\n' "No project"
          find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
        } | rofi -dmenu -i -p "Project"
      )"
    else
      PROJECT="No project"
    fi

    case "$PROJECT" in
      ""|"No project") PROJECT_LINK="" ;;
      *) PROJECT_LINK="[[''${PROJECT}/00 Project Overview]]" ;;
    esac

    DATE="$(date +%F)"
    DESTINATION="$SOURCES_DIR/$DATE $TITLE.md"
    if [ -e "$DESTINATION" ]; then
      notify "Source already exists: $(basename "$DESTINATION")"
      exit 1
    fi

    umask 077
    TEMP_FILE="$(mktemp "$SOURCES_DIR/.source.XXXXXX")"
    trap 'rm -f "$TEMP_FILE"' EXIT

    cat > "$TEMP_FILE" <<EOF
    ---
    date: $DATE
    project: "$(yaml_escape "$PROJECT_LINK")"
    url: "$(yaml_escape "$URL")"
    type: $SOURCE_TYPE
    status: Needs Review
    ---
    EOF

    mv "$TEMP_FILE" "$DESTINATION"
    trap - EXIT
    notify "Created $(basename "$DESTINATION")"
  '';

  meta = {
    description = "Create an Obsidian source note through Rofi";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "rofi-obsidian-source";
  };
}
