{ config, pkgs, ... }:

{
  users.users.caddy.extraGroups = [ "freshrss" ];

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

    poolConfig = {
      "listen.owner" = "freshrss";
      "listen.group" = "freshrss";
      "listen.mode" = "0660";
    };
  };
}
