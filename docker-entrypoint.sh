#!/usr/bin/env bash

set -e

# ensure CLIENTPORT is correct
if [ "${CLIENTPORT}" != $(("${SERVERPORT}" - 1)) ]; then
  echo "CLIENTPORT must be exactly 1 less than SERVERPORT"
  exit 2
fi

# Change the UID if needed
if [ ! "$(id -u steam)" -eq "$UID" ]; then
  echo "Changing steam uid to $UID."
  usermod -o -u "$UID" steam
fi

# Change GID if needed
if [ ! "$(id -g steam)" -eq "$GID" ]; then
  echo "Changing steam gid to $GID."
  groupmod -o -g "$GID" steam
fi

# start the cron service
cron

if [ "$1" = '/usr/bin/run-ark.sh' ] || [ "$1" = 'run-ark.sh' ] || [ "$1" = 'run-ark' ]; then
  shift
  su-exec "$UID":"$GID" /usr/bin/run-ark.sh "$@"
else
  su-exec "$UID":"$GID" "$@"
fi
