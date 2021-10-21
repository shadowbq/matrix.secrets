# matrix.secrets
manage secrets in bash - https://github.com/shadowbq/matrix.dot.files (extracted from mono.repo)

We should never store unecrypted secrets on our machines. ***Storing un-encrypted Secret ENVs in a file is bad idea®.***

## Methodology

Store secrets as an RSA 2048 encrypted Base64 bash ENV file that gets decrypted in memory via GPG and sourced as needed into Bash.

## Usage

```shell
$> env |grep -i SECRET_TOKEN
$> secrets_load
Please enter the passphrase to unlock the OpenPGP secret key:
"scott macgregor <shadowbq@gmail.com>"
2048-bit RSA key, ID 0123456789ABCDEF,
created 2019-12-28 (main key ID 0123456789ABCDEF).

Passphrase:
$> env |grep -i SECRET_TOKEN
SECRET_TOKEN=abcdefg12345678ZYXWV
```

## Implementation 

Store secrets as ENVs on a file (`.bash_secrets`) that can be sourced from Bash, but don't write the file to the hard-drive. Instead write it RSA 2048 encrypted then Base64 as (` ~/.bash_encrypted`) and decrypt in memory and source it as needed.

It is implemented as an alias `secrets_load` which evals bash function `_secrets_decrypt` on the `~/.bash_encrypted` file using gpg keys that are pin secured.

## Setup

### Install GPG and Init

Install the GPG client

* NOTE: that on MacOS the command isn't gpg2 but rather just gpg. 

```shell
$ (macosx)> brew install gpg
$ (linux)> apt/yum install gpg|gpg2
$ (bsd) > gpg
```

Init GPG

```shell
gpg --list-keys
gpg: directory '/Users/smacgregor/.gnupg' created
gpg: keybox '/Users/smacgregor/.gnupg/pubring.kbx' created
gpg: /Users/smacgregor/.gnupg/trustdb.gpg: trustdb created
```

### Set your pin entry method (required)

You will need a pin entry application *that works(looking at you mac)*

* `brew install pinentry-mac` 
* `apt install pinentry-tty`
* `yum install pinentry-tty`

* [Install Help](https://superuser.com/questions/520980/how-to-force-gpg-to-use-console-mode-pinentry-to-prompt-for-passwords)

```shell
ls -la /usr/*/bin/pinentry*
lrwxr-xr-x  1 smacgregor  admin  39 Nov  5 09:15 /usr/local/bin/pinentry -> ../Cellar/pinentry/1.1.0_1/bin/pinentry
lrwxr-xr-x  1 smacgregor  admin  46 Nov  5 09:15 /usr/local/bin/pinentry-curses -> ../Cellar/pinentry/1.1.0_1/bin/pinentry-curses
lrwxr-xr-x  1 smacgregor  admin  45 Nov  5 09:31 /usr/local/bin/pinentry-mac -> ../Cellar/pinentry-mac/0.9.4/bin/pinentry-mac
lrwxr-xr-x  1 smacgregor  admin  43 Nov  5 09:15 /usr/local/bin/pinentry-tty -> ../Cellar/pinentry/1.1.0_1/bin/pinentry-tty
```

A pure cli experience on servers or terminal

```shell
echo "pinentry-program /usr/bin/pinentry-tty" >> ~/.gnupg/gpg-agent.conf
```

For *debian/ubuntu* you *MUST* update the alternatives

```shell
sudo update-alternatives --config pinentry
```

For *macos/OSX* you can *ALTERNATIVELY* use a GUI/popup which also works with `keychain`

```shell
brew install pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
```

Reload the GPG Agent (or kill it to force a restart)

```shell
gpg-connect-agent reloadagent /bye
# `killall gpg-agent` if that not working correctly
```

Note (This was seen as require at least on **macos**):  

```shell
env |grep GPG
GPG_TTY=/dev/ttys001
```

else  

`export GPG_TTY=$(tty)` to my `~/.bash_local`

## New Secrets - Creation Securely using RAMDisks

Given that you have a GPG KEY `0123456789ABCDEF0123456789ABCDEF`:

```shell
$> gpg --list-keys
/Users/scottmacgregor/.gnupg/pubring.kbx
----------------------------------------
pub   rsa2048 2019-12-28 [SC] [expires: 2021-12-27]
      0123456789ABCDEF0123456789ABCDEF
uid           [ultimate] scott macgregor <shadowbq@gmail.com>
sub   rsa2048 2019-12-28 [E] [expires: 2021-12-27]
```

Encrypt a bash script with contents: `export SECRET_TOKEN=abcdefg12345678ZYXWV` securely into `.bash_encrypted`

```shell
# Make your Linux secrets securely 
mkdir -p $HOME/tmpfs
mount -t tmpfs -o size=512m ramfs $HOME/tmpfs
# Make your MacOS secrets securely (macos_ramdisk is in .matrix/Darwin/bin)
macos_ramdisk mount
```

Example UNENCRYPTED `.bash_secrets` file

```shell
export SECRET_TOKEN=abcdefg12345678ZYXWV
export SECRET_CLIENT_ID=abcdefg12345678ZYXWV
export SECRET_FOO_CLIENT=abcdefg12345678ZYXWV
```

Create the `.bash_secrets` in the tmpfs

```shell
vi $HOME/tmpfs/.bash_secrets
[..Write.Secrets.here..]
cat $HOME/tmpfs/.bash_secrets | gpg --encrypt -r 0123456789ABCDEF0123456789ABCDEF --armor |base64 > ~/.bash_encrypted
```

```shell
# Wipe secrets ( Nuke: https://unix.stackexchange.com/a/271870/104660)
umount $HOME/tmpfs
macos_ramdisk umount $HOME/tmpfs
```



## Working with your GPG Keys in more than one location.

GPG: Extract private key and import on different machine
Identify your private key by running `gpg --list-secret-keys`. 
You need the ID of your private key (second column)

Run this command to export your key: `gpg --export-secret-keys $ID > ~/.ssh/my-gpg-private-key.asc`.
Copy the key to the other machine ( scp is your friend)

`scp ~/.ssh/my-gpg-private-key.asc target:~/.ssh/.`

### Register an Existing Key

To import the key on the *target-server*, run `gpg --import ~/.ssh/my-gpg-private-key.asc`.

#### Trust the newly Imported key

Ensure the keys are correct by observing the ID with LONG format:

`gpg --keyid-format 0xLONG -k`

Everything showed up as normal **except** for the uid which now reads `[unknown]`:

```shell
uid [ unknown ] User < user@useremail.com >
```

Bump that trust, because its yours!

```shell
$> gpg --edit-key user@useremail.com
gpg> trust

Please decide how far you trust this user to correctly verify other users\' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y
gpg> save
```

Validate it is now `ultimate` trust.

`gpg --keyid-format 0xLONG -k`

```shell
uid [ ultimate ] User < user@useremail.com >
```

## Loading of Secrets - Manual Implementation

As an alternative to `secrets_load`,  you can manually decrypt and load into current `tty` ENV.

``` shell
$> eval $(cat ~/.bash_encrypted |base64 -d |gpg --decrypt 2> /dev/null)
```
