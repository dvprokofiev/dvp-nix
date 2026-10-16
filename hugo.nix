{ config, pkgs, ... }:

let
  siteDir = "/var/www/hugo-site";
  repoDir = "/var/www/hugo-repo";
in
{
  sops.secrets."webhook_secret" = {
    owner = "webhook";
    group = "webhook";
    mode = "0440";
  };

  sops.templates."webhook.yaml" = {
    owner = "webhook";
    group = "webhook";
    restartUnits = [ "webhook.service" ];
    content = ''
      - id: deploy-site
        execute-command: ${pkgs.coreutils}/bin/touch
        pass-arguments-to-command:
          - source: string
            name: /run/webhook/deploy-trigger
        response-message: ok
        trigger-rule:
          match:
            type: payload-hmac-sha256
            secret: "${config.sops.placeholder.webhook_secret}"
            parameter:
              source: header
              name: X-Hub-Signature-256
    '';
  };

  systemd.tmpfiles.rules = [
    "d /run/webhook 0750 webhook webhook - -"
    "d ${siteDir} 0755 hugo caddy - -"
    "Z ${siteDir} 0755 hugo caddy - -"
    "d ${repoDir} 0750 hugo caddy - -"
    "Z ${repoDir} 0750 hugo caddy - -"
  ];

  services.caddy = {
    enable = true;
    virtualHosts."dvprokofiev.ru" = {
      extraConfig = ''
        root * ${siteDir}/public
        file_server

        handle /hooks* {
          reverse_proxy localhost:9000
        }
      '';
    };
  };

  systemd.services.deploy-hugo = {
    description = "Clone and build Hugo site";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [
      git
      hugo
      bash
      go
    ];
    environment = {
      HOME = "/var/lib/hugo";
    };
    script = ''
      set -e
      if [ ! -d "${repoDir}/.git" ]; then
        git clone https://github.com/dvprokofiev/dvprokofiev.ru "${repoDir}"
      fi
      cd "${repoDir}"

      git fetch --all
      git reset --hard origin/main

      rm -rf ${siteDir}/public/*
      mkdir -p ${siteDir}/public

      hugo --minify -d ${siteDir}/public
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "hugo";
      Group = "hugo";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [
        siteDir
        repoDir
        "/var/lib/hugo"
      ];
    };
  };

  systemd.paths.deploy-trigger = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathModified = "/run/webhook/deploy-trigger";
    pathConfig.Unit = "deploy-hugo.service";
  };

  systemd.services.webhook = {
    description = "Hugo Deploy Webhook";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.webhook}/bin/webhook -port 9000 -hooks ${
        config.sops.templates."webhook.yaml".path
      } -verbose";
      User = "webhook";
      Group = "webhook";
      Restart = "always";
      RuntimeDirectory = "webhook";
      RuntimeDirectoryMode = "0750";
    };
  };

  users.users.hugo = {
    isSystemUser = true;
    group = "hugo";
    extraGroups = [ "caddy" ];
    home = "/var/lib/hugo";
    createHome = true;
  };
  users.groups.hugo = { };

  users.users.webhook = {
    isSystemUser = true;
    group = "webhook";
  };
  users.groups.webhook = { };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
