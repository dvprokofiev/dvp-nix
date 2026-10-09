{ pkgs, ... }:

{

  # apply deployer user to write to nix store
  nix.settings.trusted-users = [
    "root"
    "deployer"
  ];

  #
  users.users.deployer = {
    isSystemUser = true;
    group = "deployer";
    shell = pkgs.bashInteractive;
    createHome = true;
    home = "/home/deployer";
  };
  users.groups.deployer = { };

  # passwordless colmena
  security.sudo.extraRules = [
    {
      users = [ "deployer" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set *";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/nix/store/*/bin/switch-to-configuration *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
