{ pkgs, ... }:

{
  home.username = "sanz";
  home.homeDirectory = "/home/sanz";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
