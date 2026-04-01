{ config, pkgs, ... }:

{
  users.users.caddy.extraGroups = [
    "nginx"
    "freshrss"
  ];

  sops.secrets."freshrss_password" = {
    owner = config.services.freshrss.user;
  };

  services.freshrss = {
    enable = true;

    webserver = "caddy";
    virtualHost = "rss.dvprokofiev.ru";

    language = "ru";
    defaultUser = "dvprokofiev";
    passwordFile = config.sops.secrets."freshrss_password".path;

    baseUrl = "https://rss.dvprokofiev.ru";

    database = {
      type = "sqlite";
    };
  };
}
