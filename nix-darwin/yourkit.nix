{
  stdenv,
  fetchzip,
  zlib,
  openjdk11,
}:
let
  src = fetchzip {
    url = "https://archive.yourkit.com/yjp/2022.9/YourKit-JavaProfiler-2022.9-b183.zip";
    sha256 = "sha256-gnn7AbzOxLtVtIp5//aknsGzOPgB0IcDzrvkiKQtfVs=";
  };
in
stdenv.mkDerivation {
  name = "yourkit";
  inherit src;
  buildInputs = [ zlib ];
  buildPhase = ''
    mkdir -p $out/bin
    cp -r $src/{lib,probes,license*} $out
    find bin -maxdepth 1 -type f -exec cp {} $out/bin \;
    cp -r bin/*/ $out/bin
    # why bother fixing linking, when you can fool it with something that works
    ln -s ${openjdk11}/ $out/jre64
  '';
  installPhase = ":";
}
