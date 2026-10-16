{ config, pkgs, ... }:

{

  users.users.syncthing.extraGroups = [ "vaultwarden" ];

  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";
    dataDir = "/var/lib/syncthing";
    configDir = "/var/lib/syncthing/.config/syncthing";

    openDefaultPorts = true;

    guiAddress = "127.0.0.1:8384"; # Turn Web GUI off (don't open 8384 and use only localhost)

    settings = {
      devices = {
        "ThinkPad" = {
          id = "IU7ZBUB-TW7BGYR-VL3SAR4-UH5WFXU-6F6YUH6-474LYZD-IMDS7ZF-AQPUXAQ";
          autoAcceptFolders = true;
        };
        "mainframe" = {
          id = "HVFCZYI-BBEFVXB-2OWK3PS-6YEEQW5-G4ASGVR-F4D7DDG-A37FO3N-KBDR6QV";
          autoAcceptFolders = true;
        };
        "kukui" = {
          id = "BG3N6IM-J5UHRG4-FFNAZW4-RVVRAS4-6N4J7S6-ZNOWQJ4-J7JUWOC-76STJQ3";
          autoAcceptFolders = true;
        };
        "iPhone" = {
          id = "MGNT7IP-I6VIWQY-HKIDZOU-7IRUQJG-IY5HK7C-HMTAVEB-YVQ2BON-PQX74AZ";
          autoAcceptFolders = true;
        };
      };

      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = true;
        relaysEnabled = true;
        defaultFolderPath = "/var/lib/syncthing";
      };
    };
  };
}
