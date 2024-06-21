{ stdenv, fetchzip, ... }:
let
  jdk11 = stdenv.mkDerivation {
    pname = "yandex-jdk";
    version = "11.0.22+7";
    src = fetchzip {
      url = "https://proxy.sandbox.yandex-team.ru/5909068951";
      hash = "sha256-ql7jfHZvVctMHiiF7bxB1/wLE/K4PPc0JBfYoSUG68A";
      extension = "tar.gz";
      stripRoot = false;
    };
    buildPhase = ''
      mkdir -p $out/lib/
      cp -r $src $out/lib/openjdk

      ln -s $out/lib/openjdk/bin $out/bin
    '';
    passthru = {
      home = "${jdk11}/lib/openjdk";
    };
  };
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
  inherit jdk11 jdk17;
}
