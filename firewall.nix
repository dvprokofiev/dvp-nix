{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22 # SSH
      80
      443 # HTTP/HTTPS

      # --- Mailserver ---
      25 # SMTP
      465 # SMTPS
      587 # SMTP Submission
      993 # IMAPS

      # --- SYNCTHING ---
      22000 # Syncthing Transfer
    ];

    allowedUDPPorts = [
      22000 # Syncthing Transfer
      21027 # Syncthing Discovery
    ];
  };
}
