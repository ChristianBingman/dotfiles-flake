#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title pass
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔐
# @raycast.argument1 { "type": "text", "placeholder": "Path" }
# @raycast.argument2 { "type": "text", "placeholder": "Copy OTP", "optional": true }

#PASS="$($HOME/.nix-profile/bin/gpg -d $(find $HOME/.password-store -type f | head -n1))"
#STATUS=$?
#if [ $STATUS -ne 0 ]; then
#  killall gpg-agent
#fi

FINDPASS="$(find $HOME/.password-store -type f | grep "$1" | awk '{ print length(), $0 | "sort -n" }' | sed 's/.*\.password-store\///'| sed 's/\.gpg$//' | head -n1)"

if [ -z $FINDPASS ]
then
  echo "No Password Found!"
  exit 0
fi

if [ -z "$2" ]; then
  if $HOME/.nix-profile/bin/pass -c $FINDPASS 2> /dev/null
  then
    echo "$FINDPASS Copied"
  else
    echo "Unable to find: $FINDPASS"
  fi
else
  if $HOME/.nix-profile/bin/pass otp -c $FINDPASS 2> /dev/null
  then
    echo "$FINDPASS OTP Copied"
  else
    echo "$FINDPASS not found!"
  fi
fi


