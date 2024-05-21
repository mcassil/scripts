#!/bin/bash
# Autor: Maciel Castro
# E-mail: macielcastro@rocketmail.com
# Distro: Ubuntu 22.04
apt update
apt upgrade
apt install xrdp ssl-cert -y
# xrdp precisa dos certificados para funcionar
usermod -a -G ssl-cert xrdp
systemctl reload-or-restart xrdp
# Libera a porta 3389 no firewall
ufw allow from 192.168.1.0/24 to any port 3389 
# OBS: recomendo o Remmina para acesso remoto.
