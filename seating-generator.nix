{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "seating-backend" = {
        image = "ghcr.io/dvprokofiev/seating-generator-engine:latest";
        ports = [ "8091:5000" ];
      };

      "seating-frontend" = {
        image = "ghcr.io/dvprokofiev/seating-generator-frontend:latest";
        ports = [ "8092:80" ];
        environment = {
          BACKEND_PORT = "8091";
        };
        dependsOn = [ "seating-backend" ];
      };

      "watchtower" = {
        image = "nickfedor/watchtower:latest";
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        environment = {
          WATCHTOWER_POLL_INTERVAL = "60";
          WATCHTOWER_CLEANUP = "true";
        };
      };
    };
  };

  services.caddy.virtualHosts."seating-generator.ru" = {
    extraConfig = ''
      handle_path /api/* {
          reverse_proxy 127.0.0.1:8091
      }

      handle {
          reverse_proxy 127.0.0.1:8092
      }
    '';
  };
}
