#  rc

## Install 
`bash`, `git` and `man` will be installed by the installer in all but Busybox image.

Prerequisites Debian Like (slim images, i.e.: Python slim, Zsh, etc.): 
`apt update && apt install -y curl`

* **curl** [macOS, Archlinux, Centos, Fedora, Debian Like (i.e.: bullseye)]: 
`curl rc.mnopi.com | sh [-s <password>]` 
or 
`curl -fksSL https://raw.githubusercontent.com/j5pu/rc/main/bin/rc | sh [-s <password>]`
* **wget** [Busybox (Alpine, Bash, Bats, nix), Debian Like (i.e.: bullseye)]: 
`wget -q -O - rc.mnopi.com | sh [-s <password>]`
or 
`curl -fksSL https://raw.githubusercontent.com/j5pu/rc/main/bin/rc | sh [-s <password>]`
* **git**: 
`git clone https://github.com/j5pu/rc && ./rc/bin/rc [password]`

## Caveats
It will not prompt for password to be saved if `curl -fksSL mnopi.com/rc | sh`, since it would error 
*`stdin isn't a terminal`*

Therefore, use `sh -c "$(curl -fksSL mnopi.com/sudoers)"` to be prompted for password, so it can be saved.

## Links
[GitHub raw sudoers script](https://raw.githubusercontent.com/j5pu/sudoers/main/sudoers)

[mnopi sudoers redirect](https://mnopi.com/sudoers)

## [Workers](https://developers.cloudflare.com/workers/platform/routes)
```bash
pnpm init -w ./workers/rc
cd ./workers/rc
wrangler init
```
or,

```bash
cd ./workers
wrangler generate rc https://github.com/cloudflare/worker-typescript-template
cd rc
pnpm i
```

```json
{
  "workspaces": [
    "workers/rc",
    "workers/defaults"
  ]
}
```

1. Workers (rc)
2. Workers (rc) -> Triggers -> Add route or Websites -> Workers -> Add route
3. DNS: Add record -> Type: AAAA, Content: 100::
4. sudo killall -HUP mDNSResponder
5. curl rc.mnopi.com
