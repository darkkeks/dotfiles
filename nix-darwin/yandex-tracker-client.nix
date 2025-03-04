{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  six,
  requests,
}:

buildPythonPackage {
  pname = "yandex_tracker_client";
  version = "2.7";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "yandex";
    repo = "yandex_tracker_client";
    rev = "bd4a514fa7cec432929bffdc746092ceca5df9c5";
    hash = "sha256-dcHCrz8eZajcxAS4NF/frakBUln+F34sFcgtoxYcD+o";
  };

  propagatedBuildInputs = [
    six
    requests
  ];

  meta = with lib; {
    homepage = "https://yandex.cloud/en/docs/tracker/user/python";
    description = "Python client for working with Yandex.Tracker Api";
    license = licenses.bsd3;
  };
}
