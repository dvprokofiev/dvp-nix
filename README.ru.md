# NixOS конфиг для моего сервера

[English](./README.en.md)

> [!IMPORTANT]
> Этот конфиг НЕ ПРЕДНАЗНАЧЕН для развертывания на ваших серверах и иных вычислительных устройствах. Он существует для того, чтобы такие же заинтересованные в Nix люди могли почерпнуть для себя что-то полезное

## Что здесь происходит?

Развертываются:
- почтовый сервер при помощи [SNM](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver)
- [мой веб-сайт](https://dvprokofiev.ru), написанный на Hugo автоматически пересобирается при любом изменении GitHub репозитория
- инстанс FreshRSS
- Syncthing
- Vaultwarden, бекапы через Syncthing
- мой [генератор рассадок](https://github.com/dvprokofiev/seating-generator)