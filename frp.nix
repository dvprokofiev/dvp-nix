{ config, pkgs, ... }: {

  sops.secrets.frp_token = {
    owner = "nobody";
    group = "nogroup";
  };

  sops.templates."frps.toml" = {
    owner = "nobody";
    group = "nogroup";
    content = ''
      bindPort = 7000
      auth.token = "${config.sops.placeholder.frp_token}"
    '';
  };

  services.frp = {
    enable = true;
    role = "server";
  };

  systemd.services.frps = {
    wants = [ "sops-nix.service" ];
    after = [ "sops-nix.service" ];

    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.frp}/bin/frps -c ${config.sops.templates."frps.toml".path}"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    7000
    8080
  ];
}
