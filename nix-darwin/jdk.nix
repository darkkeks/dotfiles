{
  stdenv,
  fetchurl,
  fetchzip,
  ...
}:
let
  jdk8 = stdenv.mkDerivation {
    pname = "yandex-jdk";
    version = "8u202";
    src = fetchzip {
      url = "https://proxy.sandbox.yandex-team.ru/1901326056";
      hash = "sha256-AR0vHpU4gmyJAKmZuw3/REeyhTOPo82VxxHYfk3PHmY=";
      extension = "tar";
      stripRoot = false;
    };
    buildPhase = ''
      mkdir -p $out/lib/
      cp -r $src $out/lib/openjdk

      ln -s $out/lib/openjdk/bin $out/bin
    '';
    passthru = {
      home = "${jdk8}/lib/openjdk";
    };
    meta = {
      platforms = [ "aarch64-darwin" ];
    };
  };
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
    meta = {
      platforms = [ "aarch64-darwin" ];
    };
  };
  yandexInternalRootCA = fetchurl {
    url = "https://crls.yandex.net/YandexInternalRootCA.crt";
    hash = "sha256-DJNHNUfZnEyDQZGO0lyR5FY5suDZVw0xY4fasyG0Ca0";
  };
  jdk15 = stdenv.mkDerivation {
    pname = "yandex-jdk";
    version = "15.0.1";
    src = fetchzip {
      url = "https://proxy.sandbox.yandex-team.ru/2107376046";
      hash = "sha256-6M+UAux9N3wDSSCdN5rpXpuoSP1PgVoN6sMec7Iombc";
      extension = "tar.gz";
      stripRoot = false;
    };
    buildPhase = ''
      mkdir -p $out/lib/
      cp -r $src $out/lib/openjdk

      ln -s $out/lib/openjdk/bin $out/bin

      chmod +w $out/lib/openjdk/lib/security/cacerts
      $src/bin/keytool -keystore $out/lib/openjdk/lib/security/cacerts -keypass changeit -storepass changeit -importcert -alias yandexinternalrootca -file ${yandexInternalRootCA} -noprompt
    '';
    passthru = {
      home = "${jdk15}/lib/openjdk";
    };
    meta = {
      platforms = [ "aarch64-darwin" ];
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
    meta = {
      platforms = [ "aarch64-darwin" ];
    };
  };
  jdk21 = stdenv.mkDerivation {
    pname = "yandex-jdk";
    version = "21.0.5+11";
    src = fetchzip {
      url = "https://proxy.sandbox.yandex-team.ru/7830390213";
      hash = "sha256-KaucDh5kYkzMcavzlEkbycCWVAsTpKJZeUJFwrMtk9M=";
      extension = "tar.gz";
      stripRoot = false;
    };
    buildPhase = ''
      mkdir -p $out/lib/
      cp -r $src $out/lib/openjdk

      ln -s $out/lib/openjdk/bin $out/bin
    '';
    passthru = {
      home = "${jdk21}/lib/openjdk";
    };
    meta = {
      platforms = [ "aarch64-darwin" ];
    };
  };
in
{
  inherit
    jdk8
    jdk11
    jdk15
    jdk17
    jdk21
    ;
}
