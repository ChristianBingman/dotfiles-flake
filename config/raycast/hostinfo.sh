#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title hostinfo
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📔
# @raycast.argument1 { "type": "text", "placeholder": "hostname" }

export SSH_AUTH_SOCK=$($HOME/.nix-profile/bin/gpgconf --list-dirs agent-ssh-socket)

ssh dev148.meraki.com sh -c "cat /var/local/meraki/inventory/machines_map.json  | jq \".[] | select(.name == \"$1\")\""

