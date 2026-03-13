{
  description = "NixOS simple install with Disko";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
    simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, sops-nix, simple-nixos-mailserver, ... }: {
    nixosConfigurations.my-server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        sops-nix.nixosModules.sops
        simple-nixos-mailserver.nixosModule
        ./mailserver.nix
        ./hugo.nix
        disko.nixosModules.disko
        ({ config, pkgs, lib, ... }: {
          disko.devices.disk.main = {
            type = "disk";
            device = lib.mkDefault "/dev/vda";
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  size = "1M";
                  type = "EF02"; 
                };
                ESP = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                root = {
                  name = "root";
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };

          boot.loader = {
            grub = {
              enable = true;
              efiSupport = false;
            };
          };

          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "prohibit-password";
          };

          services.comin = {
            enable = true;
            remotes = [{
              name = "origin";
              url = "https://github.com/dvprokofiev.ru/dvp-nix";
              branches = [ "main" ];
            }];
          };

          boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "ahci" "sd_mod" ];

          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9NvoW5oFTm3Sx/Mf4fwg67ftYYvQMpB0tz7XciAHzW daniiil@daniiil-20jjs0cu1m"
          ];

          sops = {
            defaultSopsFile = ./secrets/secrets.yaml; 
            age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
          system.stateVersion = "25.05";
        })
      ];
    };
  };
}