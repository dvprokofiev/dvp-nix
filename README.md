# My NixOS server config

>[!DISCLAIMER]
> This is not a kind of config that you should just ```git clone``` and use. It's here because I think that it can be useful for some kind of people interested in NixOS, servers, etc.

## What's going on here?

- mail server with the help of [SNM](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver)
- [my website](https://dvprokofiev.ru/en) which is written in Hugo and rebuilds every time I do ```git push```
- FreshRSS
- Syncthing
- Vaultwarden which saves backups to Syncthing
- a project of mine, [seating generator](https://github.com/dvprokofiev/seating-generator)