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
    content = ''
    - id: deploy-site
      execute-command: ${pkgs.coreutils}/bin/touch
      pass-arguments-to-command:
        - source: string
          name: /tmp/deploy-trigger
      response-message: ok
      trigger-rule:
        match:
          type: payload-hmac-sha1
          secret: ${config.sops.placeholder.webhook_secret}
          parameter:
            source: header
            name: X-Hub-Signature
    '';
  };

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
    path = with pkgs; [ git hugo bash ];
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
      chown -R caddy:caddy ${siteDir}
    '';
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "root";
  };

  systemd.paths.deploy-trigger = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathModified = "/tmp/deploy-trigger";
    pathConfig.Unit = "deploy-hugo.service";
  };

  systemd.services.webhook = {
    description = "Hugo Deploy Webhook";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.webhook}/bin/webhook -port 9000 -hooks ${config.sops.templates."webhook.yaml".path} -verbose";
      User = "webhook";
      Group = "webhook";
      Restart = "always";
    };
  };

  users.users.webhook = { isSystemUser = true; group = "webhook"; };
  users.groups.webhook = {};

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}