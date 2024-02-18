{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    nixosModules.customFormats = {config, lib, ...}: {
      formatConfigs.proxmox = { ... }: {
        qemuExtraConf = { # naughty restore permissions test
          hostpci1 = "0000:04:00,pcie=1";
          spice_enhancements = "foldersharing=1,videostreaming=all";
        };
      };

      formatConfigs.azure = {config, lib, ...}: {
        fileExtension = ".vhd";
      };

      formatConfigs.docker = {config, lib, ...}: {
        services.resolved.enable = false;
        services.qemuGuest.enable = lib.mkForce false;
      };

      formatConfigs.oracle = {config, modulesPath, ...}: {
        imports = [
          "${toString modulesPath}/virtualisation/oci-image.nix"
        ];

        formatAttr = "OCIImage";
        fileExtension = ".qcow2";
      };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        nixos-generators.nixosModules.all-formats
        self.nixosModules.customFormats
        ./configuration.nix
      ];
    };
  };
}
