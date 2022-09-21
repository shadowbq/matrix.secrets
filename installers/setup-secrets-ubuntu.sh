#!/usr/bin/env bash
set -euo pipefail
echo '---###---###---###---###---###---###'
sudo apt install gnupg pinentry-tty -y
gpg --list-keys
sudo update-alternatives --install /usr/bin/pinentry pinentry /usr/bin/pinentry-tty 200
gpg-connect-agent reloadagent /bye
curl -O -J -L "https://raw.githubusercontent.com/shadowbq/matrix.secrets/main/bash/.matrix.secrets" > ~/.matrix.secrets
echo '---###---###---###---###---###---###'
echo 'Load secrets in this bash session: "source ~/.matrix.secrets"'
echo 'source ~/.matrix.secrets' >> ~/.bashrc
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
echo '---###---###---###---###---###---###'
echo '# Run this command to create a new key'
echo 'gpg --full-generate-key'
echo '---###---###---###---###---###---###'
echo '# Run these commands to Load an Existing Foreign GPG Key'
echo 'export keypath="./my-gpg-private-key.asc"'
echo 'export gpg --import $keypath'
echo 'export fingerprint=$(gpg --with-colons --import-options show-only --import $keypath | grep sec | awk -F '"'"'[:;]'"'"' '"'"'{print $5}'"'"')'
echo 'echo -e "5\ny\n" | gpg --command-fd 0 --edit-key $fingerprint trust quit'
echo 'gpg --list-secret-keys'
echo '---###---###---###---###---###---###'
echo 'done.'
