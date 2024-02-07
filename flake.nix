{
  description = "The RemoteText Neovim plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    forAllSystems = gen:
      nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed
      (system: gen nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: rec {
      default = remote-text-nvim;
      remote-text-nvim = pkgs.callPackage ./. {};
    });
  };
}
