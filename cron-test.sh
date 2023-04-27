#!/usr/bin/env bash

# not appending to file because we don't want to end up with a massive crontab-test.log
echo "hello from cron: $(date) - $(whoami)" >/ark/log/crontab-test.log
