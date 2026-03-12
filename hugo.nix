{ config, pkgs, ... }:

let
  siteDir = "/var/www/hugo-site";
  repoDir = "/var/www/hugo-repo";
in
{
  sops.secrets."webhook_secret" = { };

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

  services.webhook = {
    enable = true;
    port = 9000;
    hooks = {
      deploy-site = {
        execute-command = "${pkgs.systemd}/bin/systemctl";
        pass-arguments-to-command = [
          { source = "string"; name = "start"; }
          { source = "string"; name = "deploy-hugo.service"; }
        ];
        trigger-rule = {
          match = {
            type = "payload-hash-sha256";
            secret = "$(cat ${config.sops.secrets."webhook_secret".path})";
            parameter = {
              source = "header";
              name = "X-Hub-Signature-256";
            };
          };
        };
      };
    };
  };


  networking.firewall.allowedTCPPorts = [ 80 443 ];
}