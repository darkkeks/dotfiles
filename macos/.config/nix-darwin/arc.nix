{ stdenv, fetchurl, python3, ... }:
let
  arcDl = fetchurl {
    # https://a.yandex-team.ru/arcadia/devtools/homebrew/tap/arc-launcher.rb?rev=r11023060
    url = "http://s3.mds.yandex.net/sandbox-3185/4205418808/arc";
    hash = "sha256-52sAmTvMhTOFC2NdMpvgnqpdYZzOibC9EWqjkaSTCbw=";
  };
  arc = stdenv.mkDerivation {
    name = "arc-launcher";
    version = "r11022921";
    buildInputs = [python3];
    dontUnpack = true;
    buildPhase = ''
      install -m0755 -D ${arcDl} $out/bin/arc
    '';
  };
in arc
