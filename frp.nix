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
    extraArgs = [
      "-c"
      config.sops.templates."frps.toml".path
    ];
  };

  systemd.services.frps = {
    wants = [ "sops-nix.service" ];
    after = [ "sops-nix.service" ];
  };

  networking.firewall.allowedTCPPorts = [
    7000
    8080
  ];
}
