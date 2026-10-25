{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        let

          buildInputs = with pkgs; [
            stdenv.cc.cc.lib
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          devPackages = [
            pkgs.gcc
          ];

        in
        {
          devShells = {
            default = pkgs.mkShell {
              inherit LD_LIBRARY_PATH buildInputs;
              packages = devPackages;
            };
          };

        };
    };
}
