#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title decode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔐
# @raycast.argument1 { "type": "text", "placeholder": "encoded" }

export SSH_AUTH_SOCK=$($HOME/.nix-profile/bin/gpgconf --list-dirs agent-ssh-socket)

ssh dev148.meraki.com ./decode.sh $1

