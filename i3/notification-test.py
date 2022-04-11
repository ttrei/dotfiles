#!/usr/bin/env python

# https://wiki.archlinux.org/title/Desktop_notifications#Python

# Make sure your notification daemon is running (e.g., dunst)

# Install PyGObject with pip on Debian:
# $ sudo apt install libgirepository1.0-dev
# $ pip install PyGObject

from gi.repository import Gio

Application = Gio.Application.new("hello.world", Gio.ApplicationFlags.FLAGS_NONE)
Application.register(cancellable=None)
Notification = Gio.Notification.new("Hello world")
Notification.set_body("This is an example notification.")
Icon = Gio.ThemedIcon.new("dialog-information")
Notification.set_icon(Icon)
Application.send_notification(None, Notification)
