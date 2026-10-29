{
  description = "Modular nix-darwin configuration for macOS (Apple Silicon)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # Plain repo of eza theme files; tracks main, bumped by `make update`
    eza-themes = { url = "github:eza-community/eza-themes"; flake = false; };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, eza-themes, ... }:
    let
      # Per-machine and gitignored (written by bootstrap.sh), so the flake must be
      # built as path:<repo>, which sees untracked files; the Makefile does that
      host = import ./host.nix;
      inherit (host) user hostname fullName email timeZone;
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit self user hostname fullName email timeZone eza-themes; };
        modules = [
          ./modules/system.nix
          ./modules/defaults.nix
          ./modules/packages.nix
          ./modules/fonts.nix
          ./modules/tex.nix
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/homebrew.nix
          home-manager.darwinModules.home-manager
          ./modules/home.nix
        ] ++ nixpkgs.lib.optional (host.optional or false) ./modules/optional.nix;
      };
    };
}
