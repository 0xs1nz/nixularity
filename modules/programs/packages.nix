{ pkgs, ... }:


{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    roboto-mono
  ];

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    # Hyprland and Quickshell
    quickshell
    hyprlock
    hyprpolkitagent
    hyprshot
    hyprpaper
    rofi
    waybar
    kitty

    # Qt support
    qt6Packages.qtwayland
    qt6Packages.qt5compat

    # Wallpaper, screenshots and images
    awww
    mpvpaper
    grim
    slurp
    gpu-screen-recorder
    imagemagick
    matugen
    imv

    # Clipboard and notifications
    cliphist
    wl-clipboard
    libnotify

    # Networking and Bluetooth tools
    networkmanagerapplet
    blueman

    # Audio and media
    playerctl
    pavucontrol
    cava
    mpv
    ffmpeg
    ffmpegthumbnailer
    sox

    # File manager and utilities
    thunar
    thunar-archive-plugin
    thunar-volman
    tumbler
    xed
    ncdu
    zenity
    yazi

    # GTK and appearance
    glib
    gsettings-desktop-schemas
    nwg-look
    adw-gtk3
    papirus-icon-theme
    papirus-folders

    # Monitoring and hardware
    btop
    nvtopPackages.amd
    dmidecode
    lm_sensors
    brightnessctl
    gammastep

    # Terminal and development
    neovim
    eza
    fastfetch
    starship
    git
    gcc
    gdb
    cgdb
    gnumake
    hexyl
    jq
    curl
    unzip

    # Python
    python3
    python3Packages.pygobject3

    # Other applications
    obsidian
    vesktop
    rmpc
    taskwarrior2
    zed-editor
    pywal
  ];
}
