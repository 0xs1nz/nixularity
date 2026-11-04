{ pkgs, config, ... }:

{
  home.username = "sanz";
  home.homeDirectory = "/home/${config.home.username}";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;

    shellAliases = {
      nswitch = "sudo nixos-rebuild switch --flake \"$HOME/sys/nixos#nixos\"";
    };

    bashrcExtra = ''
      if [[ $- == *i* ]]; then
        PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
      fi
    '';
  };

  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/sys/cache";
    dataHome = "${config.home.homeDirectory}/sys/local/share";
    stateHome = "${config.home.homeDirectory}/sys/local/state";
    configHome = "${config.home.homeDirectory}/sys/config";

    configFile."quickshell" = {
      source = ./quickshell;
      recursive = true;
    };
    configFile."43pr".source = ./43pr;
    configFile."matugen".source = ./matugen;
    # Hyprland configuration
    configFile."hypr/hyprland.lua".text =
      builtins.replaceStrings
        [ "@QML_IMPORT_DIR@" ]
        [ "${pkgs.qt6Packages.qt5compat}/lib/qt-6/qml" ]
        (builtins.readFile ./hypr/hyprland.lua);

    # Hyprlock configuration
    configFile."hypr/hyprlock.conf".text =
      builtins.replaceStrings
        [ "@HYPR_CONFIG_DIR@" ]
        [ "${config.xdg.configHome}/hypr" ]
        (builtins.readFile ./hypr/hyprlock.conf);

    # Media integration
    configFile."hypr/scripts/now-playing.sh" = {
      source = ./hypr/scripts/now-playing.sh;
      executable = true;
    };

    # GTK theme reload
    configFile."hypr/scripts/gtk-reload.sh" = {
      source = ./hypr/scripts/gtk-reload.sh;
      executable = true;
    };

    # Screenshot area picker
    configFile."hypr/scripts/screenshot-area.sh" = {
      source = ./hypr/scripts/screenshot-area.sh;
      executable = true;
    };

    # Microphone mute toggle
    configFile."hypr/scripts/mic-mute-toggle.sh" = {
      source = ./hypr/scripts/mic-mute-toggle.sh;
      executable = true;
    };

    # Kitty — static config
    configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;

    # Rofi — static layout
    configFile."rofi/config.rasi".source = ./rofi/config.rasi;

    # Cava — static configuration
    configFile."cava/config".source = ./cava/config;

    # GTK — static stylesheets
    configFile."gtk-3.0/gtk.css".source = ./gtk-3.0/gtk.css;
    configFile."gtk-4.0/gtk.css".source = ./gtk-4.0/gtk.css;
  };

  programs.spicetify = {
    enable = true;

    theme = {
      name = "text";
      src = ./spicetify/text;
    };

    colorScheme = "Monochrome";
  };

  systemd.user.services.pr43-spotify-palette = {
    Unit = {
      Description = "43PR Spotify Palette Bridge";
    };

    Service = {
      Type = "simple";

      ExecStart =
        "${pkgs.python3}/bin/python3 ${./spicetify/palette-server.py}";

      Environment =
        "XDG_CACHE_HOME=${config.xdg.cacheHome}";

      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
