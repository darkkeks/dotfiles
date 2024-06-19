{ stdenv, fetchzip, ... }:
let
  jdk17 = stdenv.mkDerivation {
    pname = "yandex-jdk";
    version = "17.0.2";
    src = fetchzip {
      url = "https://proxy.sandbox.yandex-team.ru/2720886299";
      hash = "sha256-ile3n1d9ZX/H95qn3zEtLKkONe598xUkfYj8dcAxAJg";
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
