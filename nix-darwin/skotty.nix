{ stdenv, lib, fetchurl, pkgs, ... }:
let
  skotty-launcher-dl = pkgs.runCommand "skotty-launcher"
    {
      outputHashAlgo = "sha256";
      outputHash = "sha256-OhHxl1z7DCNBoBZiPv/awZgOO7yzFNa3EnFrn+OUduY=";
    } ''
    ${pkgs.curl}/bin/curl -k "https://tools.sec.yandex-team.ru/api/v2/dumb-proxy/skotty-launcher/0.1.15893150/skotty-launcher-darwin-amd64.zst/skotty-launcher-darwin-amd64/skotty-launcher_darwin_amd64_0.1.15893150" -o $out
  '';

  skotty-launcher = pkgs.stdenv.mkDerivation {
    name = "skotty-launcher";
    dontUnpack = true;
    buildPhase = "install -m 0755 -D ${skotty-launcher-dl} $out/bin/skotty-launcher";
  };

  skotty = pkgs.stdenv.mkDerivation {
    name = "skotty";
    dontUnpack = true;
    buildPhase = ''
      mkdir -p $out/bin
      ${skotty-launcher}/bin/skotty-launcher --self-install --self-install-dir $out/bin
    '';
  };
in skotty
