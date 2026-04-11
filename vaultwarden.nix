{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/vaultwarden 0700 vaultwarden vaultwarden -"
    "d /var/lib/vaultwarden/backups 0700 vaultwarden vaultwarden -"
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
