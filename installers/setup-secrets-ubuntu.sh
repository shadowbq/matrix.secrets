#!/usr/bin/env bash

sudo apt install gnupg pinentry-tty -y
gpg --list-keys
sudo update-alternatives --install /usr/bin/pinentry pinentry /usr/bin/pinentry-tty 200
gpg-connect-agent reloadagent /bye
curl -O -J -L "https://raw.githubusercontent.com/shadowbq/matrix.secrets/main/bash/.matrix.secrets" > ~/.matrix.secrets
echo 'Load in this session: "source ~/.matrix.secrets"'
echo 'source ~/.matrix.secrets' >> ~/.bashrc
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
echo '# Run these commands to Load an Existing Foreign GPG Key'
echo 'export keypath="./my-gpg-private-key.asc"'
echo 'export fingerprint=$(gpg --with-colons --import-options show-only --import ./my-gpg-private-key.asc | grep sec | awk -F '"'"'[:;]'"'"' '"'"'{print $5}'"'"')'
#echo 'export fingerprint=$(gpg --quiet --import-options import-show --import $keypath | sed -e "2!d" -e "s/^[ \t]*//")'
# echo 'echo "${fingerprint}:6:" | gpg --import-ownertrust'
