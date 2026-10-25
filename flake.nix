{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    kast.url = "github:kast-lang/kast/bootstrap-ocaml";
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

          kast = inputs.kast.packages.${system}.default;

          buildInputs = with pkgs; [
            stdenv.cc.cc.lib
          ];

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          devPackages = with pkgs; [
            gcc
            just

            (writeShellScriptBin "kast" ''
              systemd-run --quiet --user --scope -p MemoryMax=5G \
                rlwrap ${kast}/bin/kast "$@"
            '')
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
