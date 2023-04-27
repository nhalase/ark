#!/usr/bin/env bash

arkrunning=$(arkmanager status | sed -n 4p | sed -e 's/\x1b\[[0-9;]*m//g' | tr -d ' ' | cut -d ':' -f2)

if [[ "$arkrunning" == "Yes" ]]; then
  exit 0
else
  arkmanager restart
  exit 1
fi
