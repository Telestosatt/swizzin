#!/bin/bash
distribution=$(lsb_release -is)
codename=$(lsb_release -cs)

#shellcheck source=sources/functions/utils
. /etc/swizzin/sources/functions/utils
users=($(_get_user_list))
for u in ${users[@]}; do
    systemctl disable --now wg-quick@wg$(id -u $u)
    rm -rf /home/$u/.wireguard
done

rm -rf /etc/wireguard/

apt_remove wireguard wireguard-tools wireguard-dkms qrencode

echo "Removing unused repositories"

if [[ $distribution == "Debian" ]]; then
    rm_if_exists /etc/apt/sources.list.d/unstable.list
    rm_if_exists /etc/apt/preferences.d/limit-unstable
elif [[ $codename =~ ("bionic"|"xenial") ]]; then
    add-apt-repository -r -y ppa:wireguard/wireguard >> /dev/null 2>&1
fi

apt_update

rm /install/.wireguard.lock
