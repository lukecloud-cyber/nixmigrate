{
  description = "NixOS configurations — bare-metal (nixpc) and VM (nixvm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {

    # Bare-metal workstation (AMD GPU, gaming, virtualisation)
    nixosConfigurations.nixpc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixpc/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.luke = import ./hosts/nixpc/home.nix;
        }
      ];
    };

    # QEMU/KVM virtual machine (no GPU drivers, no gaming, SPICE guest agent)
    nixosConfigurations.nixvm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/nixvm/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.luke = import ./hosts/nixvm/home.nix;
        }
      ];
    };

  };
}
