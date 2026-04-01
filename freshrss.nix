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

    systemd.tmpfiles.rules = [
      "z /run/phpfpm/freshrss.sock 0660 nginx nginx -"
    ];
  };
}
