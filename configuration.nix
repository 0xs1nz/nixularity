# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
	imports =
	  [ # Include the results of the hardware scan.
	    ./hardware-configuration.nix
	  ];

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Use latest kernel.
	boot.kernelPackages = pkgs.linuxPackages_latest;

	networking.hostName = "nixos"; # Define your hostname.
	# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;

	# Set your time zone.
	time.timeZone = "Asia/Amman";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	i18n.extraLocaleSettings = {
  		LC_ADDRESS = "ar_JO.UTF-8";
  		LC_IDENTIFICATION = "ar_JO.UTF-8";
  		LC_MEASUREMENT = "ar_JO.UTF-8";
  		LC_MONETARY = "ar_JO.UTF-8";
  		LC_NAME = "ar_JO.UTF-8";
  		LC_NUMERIC = "ar_JO.UTF-8";
  		LC_PAPER = "ar_JO.UTF-8";
  		LC_TELEPHONE = "ar_JO.UTF-8";
  		LC_TIME = "ar_JO.UTF-8";
	};

	# Configure keymap in X11
	services.xserver.xkb = {
  		layout = "us";
  		variant = "";
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users."sanz" = {
  		isNormalUser = true;
  		description = "sanz";
  		extraGroups = [ "networkmanager" "wheel" ];
 		packages = with pkgs; [];
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	#flatpak install
	services.flatpak.enable = true;

	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
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

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	# system.copySystemConfiguration = true;

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "26.05"; # Did you read the comment?

	#
	# hyprland install
	#
	boot.initrd.kernelModules = ["amdgpu"];
	services.xserver.videoDrivers = ["amdgpu"];
	hardware.graphics.enable = true;

	services.xserver.enable = true;
	services.displayManager.sddm.enable = true;

	programs.hyprland.enable = true;
	programs.hyprland.xwayland.enable = true;
	security.polkit.enable = true;

	#
	# terminal alias's 
	#	
	environment.shellAliases = {
  		nswitch = "cp ~/sys/nixos/configuration.nix /etc/nixos/configuration.nix.bak && sudo nixos-rebuild switch -I nixos-config=/home/sanz/sys/nixos/configuration.nix";
	};
	#
	# decluttering $HOME
	#
	environment.sessionVariables = {
  		XDG_CONFIG_HOME = "$HOME/sys/config";
  		XDG_CACHE_HOME = "$HOME/sys/cache";
  		XDG_DATA_HOME = "$HOME/sys/local/share";
  		XDG_STATE_HOME = "$HOME/sys/local/state";
		XDG_DOWNLOAD_DIR="$HOME/dumps";
	};

	# systemd-boot del automation
	#
	nix.gc = {
  		automatic = true;
  		dates = "weekly";
  		options = "--delete-older-than 7d";
	};

	boot.loader.systemd-boot.configurationLimit = 5;
}
