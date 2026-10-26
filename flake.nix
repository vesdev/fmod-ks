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

          fmod-ks = pkgs.callPackage ./package.ks.nix { };

          buildInputs = fmod-ks.runtimeLibs;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          devPackages = with pkgs; [
            gcc
            just
            libbacktrace

            (writeShellScriptBin "kast" ''
              systemd-run --quiet --user --scope -p MemoryMax=5G \
                ${rlwrap}/bin/rlwrap ${kast}/bin/kast "$@"
            '')
          ];

        in
        {
          packages = {
            default = fmod-ks;
            inherit fmod-ks;
          };

          devShells = {
            default = pkgs.mkShell {
              inherit LD_LIBRARY_PATH buildInputs;
              packages = devPackages;

              shellHook = ''
                export FMOD_SDK="''${FMOD_SDK:-$PWD/fmod}"
                export FMOD_CFLAGS="${pkgs.lib.concatStringsSep " " (fmod-ks.cflags { sdk = "$FMOD_SDK"; } )}"
              '';

              KAST_PATH = "${kast}";
            };
          };

        };
    };
}
