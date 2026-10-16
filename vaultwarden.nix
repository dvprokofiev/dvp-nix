{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/vaultwarden 0700 vaultwarden vaultwarden -"
    "d /var/backup/vaultwarden 0770 vaultwarden syncthing - -"
    "d /var/backup/vaultwarden/.stfolder 0770 syncthing syncthing - -"
    "Z /var/backup/vaultwarden 0770 vaultwarden syncthing - -"
  ];

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/backup/vaultwarden";
    config = {
      DOMAIN = "https://vault.klaaan.ru";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."vault.klaaan.ru".extraConfig = ''
      reverse_proxy localhost:8222
    '';
  };
}
