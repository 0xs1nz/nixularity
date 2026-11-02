{ pkgs, ... }:

{
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    cgdb
    copyq
    eza
    fastfetch
    gcc
    git
    gnumake
    gdb
    hexyl
    hyprlock
    hyprshot
    hyprpaper
    imv
    kitty
    mpv
    neovim
    obsidian
    pywal
    rmpc
    rofi
    sox
    taskwarrior2
    thunar
    vesktop
    waybar
    wev
    yazi
    zed-editor
  ];
}
