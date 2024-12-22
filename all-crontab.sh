#!/bin/bash
# Author: Rodrigo de Avila
# Link: rdeavila/all-crontab.sh - https://gist.github.com/rdeavila/6494997
for user in $(cut -f1 -d: /etc/passwd); do echo $user; sudo crontab -u $user -l; done
