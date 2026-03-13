{ config, pkgs, lib, ... }:

let
  siteDir = "/var/www/hugo-site";
  repoDir = "/var/www/hugo-repo";
  triggerPath = "/run/deploy-trigger";
in
{
  sops.secrets."webhook_secret" = {
    owner = "webhook";
  };

  services.caddy = {
    enable = true;
    virtualHosts."dvprokofiev.ru" = {
      extraConfig = ''
        root * ${siteDir}/public
        file_server
        
        handle_path /webhook-deploy* {
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
    pathConfig.PathModified = triggerPath;
    pathConfig.Unit = "deploy-hugo.service";
  };

    services.webhook = {
      enable = true;
      port = 9000;
      hooksTemplated.hooks = builtins.toJSON [
        {
          id = "deploy-site";
          execute-command = "${pkgs.coreutils}/bin/touch";
          pass-arguments-to-command = [
            { source = "string"; name = triggerPath; }
          ];
          trigger-rule = {
            match = {
              type = "payload-hmac-sha256";
              secret = "{{ getenv \"WEBHOOK_SECRET\" }}";
              parameter = {
                source = "header";
                name = "X-Hub-Signature-256";
              };
            };
          };
        }
      ];
    };

    systemd.services.webhook.serviceConfig = {
      EnvironmentFile = config.sops.secrets."webhook_secret".path;
      PrivateTmp = false;
    };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}