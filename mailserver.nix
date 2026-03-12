{ config, pkgs, ... }:

{
  sops.secrets."d_password" = {
    neededForUsers = true;
  };

  mailserver = {
    enable = true;
    fqdn = "dvprokofiev.ru";
    domains = [ "dvprokofiev.ru" ];

    stateVersion = 3;

    x509 = {
        certificateFile = "/var/lib/acme/dvprokofiev.ru/fullchain.pem";
        privateKeyFile = "/var/lib/acme/dvprokofiev.ru/key.pem";
    };

    loginAccounts = {
      "d@dvprokofiev.ru" = {
        hashedPasswordFile = config.sops.secrets."d_password".path;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "d@dvprokofiev.ru";
    certs."dvprokofiev.ru" = {
      group = "acme";
      listenHTTP = ":80";
    };
  };

  users.users.dovecot = {
    isSystemUser = true;
    group = "dovecot";
  };
  users.groups.dovecot = {};

  users.users.postfix.extraGroups = [ "acme" ];
  users.users.dovecot.extraGroups = [ "acme" ];
}