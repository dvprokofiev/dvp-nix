{ config, pkgs, ... }:

{
  sops.secrets."d_password" = {
    neededForUsers = false; 
    owner = "dovecot";
    group = "dovecot";
    mode = "0440";
  };
    systemd.tmpfiles.rules = [
    "z /var/lib/caddy 0750 caddy caddy - -"
    "z /var/lib/caddy/.local 0750 caddy caddy - -"
    "z /var/lib/caddy/.local/share 0750 caddy caddy - -"
    "z /var/lib/caddy/.local/share/caddy 0750 caddy caddy - -"
    "z /var/lib/caddy/.local/share/caddy/certificates 0750 caddy caddy - -"
  ];

  mailserver = {
    enable = true;
    fqdn = "dvprokofiev.ru";
    domains = [ "dvprokofiev.ru" ];
    stateVersion = 3;

    x509 = {
      certificateFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/dvprokofiev.ru/dvprokofiev.ru.crt";
      privateKeyFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/dvprokofiev.ru/dvprokofiev.ru.key";
    };

    loginAccounts = {
      "d@dvprokofiev.ru" = {
        hashedPasswordFile = config.sops.secrets."d_password".path;
      };
    };
  };

  users.users.dovecot = {
    isSystemUser = true;
    group = "dovecot";
    extraGroups = [ "caddy" ];
  };

  users.users.postfix = {
    extraGroups = [ "caddy" ];
  };
  users.groups.dovecot = {};
}