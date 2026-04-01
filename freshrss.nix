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

    language = "ru";
    defaultUser = "picard";
    passwordFile = config.sops.secrets."freshrss_password".path;

    baseUrl = "https://rss.dvprokofiev.ru";

    database = {
      type = "sqlite";
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/phpfpm 0755 root root -"
    "z /run/phpfpm/freshrss.sock 0660 nginx nginx -"
  ];
}
