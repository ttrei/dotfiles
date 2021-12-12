#!/usr/bin/env bash

SELECTOR_PROGRAM="${1:-"fzf"}"
if ! [[ "$SELECTOR_PROGRAM" = "fzf" || "$SELECTOR_PROGRAM" = "rofi" ]]; then
    echo "Usage: $0 [fzf|rofi]"
    exit 1
fi

die() {
    echo "[-] Error: $1" >&2
    exit 1
}

OLD_SERVER=$(systemctl list-units --type=service --state=active \
             | grep wg-quick | awk -F '@' '{print $2}' | awk -F '.' '{print $1}')
if [ -z "$OLD_SERVER" ]; then
    echo "Could not find current active Mullvad server"
    exit 1
fi

# Inspired by https://mullvad.net/media/files/mullvad-wg.sh
RESPONSE="$(curl -LsS https://api.mullvad.net/public/relays/wireguard/v1/)" || die "Unable to connect to Mullvad API."
FIELDS=$(jq -r 'foreach .countries[] as $country (.; .; foreach $country.cities[] as $city (.; .; foreach $city.relays[] as $relay (.; .; $country.name, $city.name, $relay.hostname)))' <<<"$RESPONSE") || die "Unable to parse api.mullvad.net response."
declare -a servers
while read -r COUNTRY && read -r CITY && read -r HOSTNAME; do
    CODE="${HOSTNAME%-wireguard}"
    servers+=( "$CODE ($CITY, $COUNTRY)" )
done <<<"$FIELDS"

if [ "$SELECTOR_PROGRAM" = "fzf" ]; then
    NEW_SERVER=$(printf '%s\n' "${servers[@]}" | fzf | cut -f1 -d" ")
else
    NEW_SERVER=$(printf '%s\n' "${servers[@]}" |\
        rofi -dmenu -matching fuzzy -i -p "Choose VPN server" | cut -f1 -d" ")
fi

TORRENT_SERVICE="transmission-daemon-user.service"
WIREGUARD_TARGET="wg-quick.target"

sudo systemctl stop "$TORRENT_SERVICE"
sudo systemctl stop "$WIREGUARD_TARGET"

sudo systemctl disable "wg-quick@${OLD_SERVER}.service"
sudo systemctl enable "wg-quick@${NEW_SERVER}.service"

sudo systemctl start "$WIREGUARD_TARGET"
sudo systemctl start "$TORRENT_SERVICE"
