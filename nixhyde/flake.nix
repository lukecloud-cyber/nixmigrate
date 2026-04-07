{
  description = "NixOS + HyDE (Hyprland) — nixpc and nixvm with hydenix desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hydenix = {
      url = "github:richen604/hydenix";
      # Let hydenix use its own pinned nixpkgs for its overlay/packages,
      # but our system-level nixpkgs stays on nixos-unstable.
    };

    # MCP server for NixOS (packages, options, versions)
    mcp-nixos.url = "github:utensils/mcp-nixos";
  };

  outputs = { self, nixpkgs, home-manager, hydenix, ... }@inputs: {

    nixosConfigurations.nixpc-hyde = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Hydenix system modules (SDDM, Hyprland, PipeWire, boot, etc.)
        hydenix.nixosModules.default

        # Our system configuration
        ./nixpc-configuration.nix

        # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.luke = import ./nixpc-home.nix;
        }
      ];
    };

    nixosConfigurations.nixvm-hyde = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Hydenix system modules (SDDM, Hyprland, PipeWire, boot, etc.)
        hydenix.nixosModules.default

        # Our system configuration
        ./nixvm-configuration.nix

        # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.luke = import ./nixvm-home.nix;
        }
      ];
    };

  };
}
