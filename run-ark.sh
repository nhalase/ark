#!/usr/bin/env bash

echo "###########################################################################"
echo "# Ark Server - " "$(date)"
echo "# UID $UID - GID $GID"
echo "###########################################################################"

[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

stop() {
  if [ "${BACKUPONSTOP}" -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks)" ]; then
    echo "[Backup on stop]"
    arkmanager backup
  fi
  if [ "${WARNONSTOP}" -eq 1 ]; then
    arkmanager stop --warn
  else
    arkmanager stop
  fi
}

[ ! -d /ark/log ] && mkdir /ark/log
[ ! -d /ark/backup ] && mkdir /ark/backup
[ ! -d /ark/staging ] && mkdir /ark/staging

if [ ! -d /ark/server ] || [ ! -f /ark/server/version.txt ]; then
  echo "No game files found. Installing..."
  arkmanager install --verbose
else
  if [ "${BACKUPONSTART}" -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks/)" ]; then
    echo "[Backup]"
    arkmanager backup
  fi
fi

# Launching ark server
if [ "$UPDATEONSTART" -eq 0 ]; then
  arkmanager start --noautoupdate --verbose "$@"
else
  arkmanager start --verbose "$@"
fi

# Installing crontab for user steam
echo "Loading crontab..."
crontab "$ARK_CRONTAB"

# Stop server in case of signal INT or TERM
echo "Waiting..."
trap stop INT
trap stop TERM

read -r </tmp/FIFO &
wait
