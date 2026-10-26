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
  };
}
