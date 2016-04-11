xset s 0          # screen blanking timeout (seconds, 0 = disabled)
xset dpms 0 0 600 # monitor power saving timeouts:
                  # <Standby> <Suspend> <Off> (seconds, 0 = disabled)

sh ~/.fehbg & # restore wallpaper

exec /etc/alternatives/x-window-manager
