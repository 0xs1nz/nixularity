{
  imports = [
    ../../hardware-configuration.nix

    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/users.nix
    ../../modules/system/nix.nix
    ../../modules/system/audio.nix

    ../../modules/hardware/graphics.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/programs/packages.nix
  ];

  environment.shellAliases = {
    nswitch = "sudo nixos-rebuild switch --flake ~/sys/nixos#nixos";
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/sys/config";
    XDG_CACHE_HOME = "$HOME/sys/cache";
    XDG_DATA_HOME = "$HOME/sys/local/share";
    XDG_STATE_HOME = "$HOME/sys/local/state";
    XDG_DOWNLOAD_DIR = "$HOME/dumps";
  };
}
