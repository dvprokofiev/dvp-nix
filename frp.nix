{ config, pkgs, ... }: {

  sops.secrets.frp_token = {
    restartUnits = [ "frp-server.service" ];
  };

  services.frp.instances.server = {
    enable = true;
    role = "server";

    environmentFiles = [ config.sops.secrets.frp_token.path ];

    settings = {
      bind_port = 7000;
      auth.token = "$FRP_AUTH_TOKEN";
    };
  };
}
