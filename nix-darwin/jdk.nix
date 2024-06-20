{ stdenv, fetchzip, ... }:
let
  jdk17 = stdenv.mkDerivation {
    pname = "yandex-jdk";
    version = "17.0.2";
    src = fetchzip {
      url = "https://proxy.sandbox.yandex-team.ru/2720893567";
      hash = "sha256-YDwhns99iq7WWIrfQz45Ktdh749w+ioVaFFFvbsZ2L4";
      extension = "tar.gz";
      stripRoot = false;
    };
    buildPhase = ''
      mkdir -p $out/lib/
      cp -r $src $out/lib/openjdk

      ln -s $out/lib/openjdk/bin $out/bin
    '';
    passthru = {
      home = "${jdk17}/lib/openjdk";
    };
  };
in {
  inherit jdk17;
}
