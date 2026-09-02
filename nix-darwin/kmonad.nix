{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.kmonad;

  karabiner-virtualhiddevice = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
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
      echo "Starting Karabiner-VirtualHIDDevice daemon" >&2
      launchctl unload /Library/LaunchDaemons/${karabiner-virtualhiddevice}.plist
      launchctl load -w /Library/LaunchDaemons/${karabiner-virtualhiddevice}.plist

      echo "Starting kmonad daemon" >&2
      launchctl unload /Library/LaunchDaemons/kmonad.plist
      launchctl load -w /Library/LaunchDaemons/kmonad.plist
    '';

    # TODO(darkkeks): When binary path changes needs to be added to system input monitoring whitelist manually.
    launchd.daemons.kmonad = {
      serviceConfig = {
        Label = "kmonad";
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path ${pkgs.kmonad}/bin/kmonad && exec ${pkgs.kmonad}/bin/kmonad ${cfg.config}"
        ];
        StandardOutPath = "/var/log/kmonad.out.log";
        StandardErrorPath = "/var/log/kmonad.err.log";
        RunAtLoad = true;
        KeepAlive = true;
      };
    };

    # From https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/blob/v5.0.0/files/LaunchDaemons/org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon.plist.
    launchd.daemons.karabiner-virtualhiddevice = {
      serviceConfig = {
        Label = "${karabiner-virtualhiddevice}";
        ProcessType = "Interactive";
        KeepAlive = true;
        ProgramArguments = [
          "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
        ];
      };
    };
  };
}
