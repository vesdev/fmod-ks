{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-25-11.url = "nixpkgs/nixos-25.11";
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

          pkgs-25-11 = import inputs.nixpkgs-25-11 { inherit system; };
          emscripten = pkgs-25-11.emscripten;

          fmod-ks = pkgs.callPackage ./package.ks.nix { };

          get-fmod = pkgs.writers.writePython3Bin "get-fmod"
            { libraries = ps: [ ps.requests ]; }
            (builtins.readFile ./get_fmod.py);

          buildInputs = fmod-ks.runtimeLibs;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          devPackages = with pkgs; [
            gcc
            just
            libbacktrace
            caddy
            emscripten
            get-fmod

            (writeShellScriptBin "kast" ''
              systemd-run --quiet --user --scope -p MemoryMax=5G \
                ${rlwrap}/bin/rlwrap ${kast}/bin/kast "$@"
            '')
          ];

        in
        {
          packages = {
            default = fmod-ks;
            inherit fmod-ks get-fmod;
          };

          devShells = {
            default = pkgs.mkShell {
              inherit LD_LIBRARY_PATH buildInputs;
              packages = devPackages;

              shellHook = ''
                export FMOD_SDK="''${FMOD_SDK:-$PWD/fmod/linux}"
                export FMOD_CFLAGS="${pkgs.lib.concatStringsSep " " (fmod-ks.cflags { sdk = "$FMOD_SDK"; } )}"

                export FMOD_WEB_SDK="''${FMOD_WEB_SDK:-$PWD/fmod/html5}"
                export FMOD_EMCC_FLAGS="${pkgs.lib.concatStringsSep " " (fmod-ks.webCflags { sdk = "$FMOD_WEB_SDK"; logging = true; } )}"
                export FMOD_EMCC_FLAGS_THREADS="${pkgs.lib.concatStringsSep " " (fmod-ks.webCflags { sdk = "$FMOD_WEB_SDK"; threads = true; logging = true; } )}"
              '';

              KAST_PATH = "${kast}";
            };
          };

        };
    };
}
