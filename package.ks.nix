# scuffed package definition
{ lib, stdenv, stdenvNoCC, libpulseaudio, alsa-lib }:

stdenvNoCC.mkDerivation {
  name = "fmod-ks";

  src = lib.fileset.toSource {
    root = ./.;

    fileset = lib.fileset.unions [
      ./src
      ./LICENSE
    ];

  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r src $out/src
    cp LICENSE $out/LICENSE
  '';

  passthru = {
    kastDeps = [ ];

    runtimeLibs = [
      stdenv.cc.cc.lib
      libpulseaudio
      alsa-lib
    ];

    cflags = { sdk }: [
      "-I${sdk}/api/core/inc"
      "-I${sdk}/api/studio/inc"
      "-L${sdk}/api/core/lib/x86_64"
      "-L${sdk}/api/studio/lib/x86_64"
      "-Wl,-rpath,${sdk}/api/core/lib/x86_64:${sdk}/api/studio/lib/x86_64"
      "-lfmodstudio"
      "-lfmod"
    ];

    # see: https://fmod.com/docs/2.04/api/platforms-html5.html#using-fmod-with-cc
    webCflags = { sdk, threads ? false, logging ? false }:
      let
        variant = if threads then "pthreads" else "single_threaded";
        name = "fmodstudio"
          + (if threads then "P" else "")
          + (if logging then "L" else "");
      in
      [
        "-I${sdk}/api/core/inc"
        "-I${sdk}/api/studio/inc"
        "${sdk}/api/studio/lib/browser/${variant}/c_cpp/${name}.a"
        "-sWASM=1"
        "-sALLOW_MEMORY_GROWTH=1"
        "-sEXPORTED_RUNTIME_METHODS=ccall,cwrap,setValue,getValue"
      ] ++ lib.optionals threads [
        "-pthread"
        "-sPTHREAD_POOL_SIZE=9"
        "-sAUDIO_WORKLET"
        "-sWASM_WORKERS"
      ];
  };
}
