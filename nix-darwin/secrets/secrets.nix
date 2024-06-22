let
  darkkeks = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkCVggIssZuvgppc4j//kR3h42TOhC2gWQRbpaVsQ21 v.boben@yandex.ru";
  users = [ darkkeks ];
in
{
  "maven-settings-security.age".publicKeys = users;
}
