{ config, lib, pkgs, ... }:

let
  cfg = config.services.kmonad;
in
{
  options = {
    services.kmonad = {
      enable = lib.mkEnableOption "Kmonad";
      config = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to kmonad configuration file.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.kmonad ];

    system.activationScripts.postActivation.text = ''
      echo "Starting kmonad daemon" >&2
      launchctl unload /Library/LaunchDaemons/kmonad.plist
      launchctl load -w /Library/LaunchDaemons/kmonad.plist
    '';

    # TODO(darkkeks): When binary path changes needs to be added to system input monitoring whitelist manually.
    launchd.daemons.kmonad = {
      serviceConfig = {
        Label = "kmonad";
        ProgramArguments = [
          "/bin/sh" "-c"
          "/bin/wait4path ${pkgs.kmonad}/bin/kmonad &amp;&amp; exec ${pkgs.kmonad}/bin/kmonad ${cfg.config}"
        ];
        StandardOutPath = "/var/log/kmonad.out.log";
        StandardErrorPath = "/var/log/kmonad.err.log";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };
}
