#!/usr/bin/env sh

sudo systemctl start wg-quick.target
sudo systemctl start transmission-daemon-user.service
