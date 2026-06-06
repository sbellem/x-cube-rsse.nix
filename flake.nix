{
  description = "STMicroelectronics X-CUBE-RSSe (RSS extension binaries)";

  nixConfig.allowUnfree = true;

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    xCubeRsse = pkgs.callPackage ./x-cube-rsse.nix {};
  in {
    packages.${system}.default = xCubeRsse;
  };
}
