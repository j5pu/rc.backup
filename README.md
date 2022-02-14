#  sudoers

## Install 
`bash`, `git` and `man` will be installed by the installer in all but Busybox image.

Prerequisites Debian Like (slim images, i.e.: Python slim, Zsh, etc.): 
`apt update && apt install -y curl`

* **curl** [macOS, Archlinux, Centos, Fedora, Debian Like (i.e.: bullseye)]: 
`curl -fsSL https://mnopi.com/sudoers | sh -s [password]`
* **wget** [Busybox (Alpine, Bash, Bats, nix), Debian Like (i.e.: bullseye)]: 
`wget -q -O - https://mnopi.com/sudoers | sh -s [password]`
* **git**: 
`git clone https://mnopi.com/sudoers && ./sudoers [password]`

## Links
[install raw](https://raw.githubusercontent.com/j5pu/sudoers/main/sudoers)
[install mnopi](https://mnopi.com/sudoers)

