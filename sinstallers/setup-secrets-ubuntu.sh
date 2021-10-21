#!/usr/bin/env bash

sudo apt install gnupg pinentry-tty -y
gpg --list-keys
sudo update-alternatives --config pinentry
gpg-connect-agent reloadagent /bye
curl -O -J -F "https://raw.githubusercontent.com/shadowbq/matrix.secrets/main/bash/.matrix.secrets" > ~/.matrix.secrets
echo 'source ~/.matrix.secrets' >> ~/.bashrc
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
echo '# Load an Existing Foreign GPG Key'
echo 'export keypath="./my-gpg-private-key.asc"'
echo 'export fingerprint=$(gpg --quiet --import-options import-show --import $keypath | sed -e "2!d" -e "s/^[ \t]*//")'
echo 'echo "${fingerprint}:6:" | gpg --import-ownertrust'
