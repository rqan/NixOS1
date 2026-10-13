{
  description = "NixOS Unified Configuration (Hyprland + Serpantinum Desktop Rice)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serpantinum = {
      url = "github:rqan/serpantinum";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lerd = {
      url = "github:lerd-env/lerd-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, serpantinum, silentSDDM, spicetify-nix, lerd, ... }@inputs:
    let
      system = "x86_64-linux";

      mkSystem = hostModule: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs serpantinum silentSDDM lerd spicetify-nix;
        };
        modules = [
          serpantinum.nixosModules.default
          silentSDDM.nixosModules.default
          spicetify-nix.nixosModules.default
          { environment.systemPackages = [ lerd.packages.${system}.default ]; }
          hostModule

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit spicetify-nix; };
            home-manager.users.focarix = import ./home;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        # Host profil laptop saat ini (mendukung hostname default 'focarix' maupun alias 'laptop')
        focarix = mkSystem ./hosts/laptop;
        laptop  = mkSystem ./hosts/laptop;

        # Host profil generic / PC baru
        generic = mkSystem ./hosts/generic;
      };
    };
}
