{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-ahmed"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
	enable = true;
	autoRepeatDelay = 200;
	autoRepeatInterval = 35;
	windowManager.i3 = {
		enable = true;
		extraPackages = with pkgs; [i3status i3lock dmenu];
	};
	displayManager.defaultSession = "none+i3";
  };
  services.displayManager.ly.enable = true;
  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ahmed = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkManager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    alacritty
    thunar
  ];

  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
	nerd-fonts.ubuntu
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  xdg.portal = {
	  enable = true;
	  xdgOpenUsePortal = true;

	  extraPortals = [
	    pkgs.xdg-desktop-portal-gtk
	  ];

	  config.common.default = "*";
  };

  services.dbus.enable = true;
  
  services.pipewire = {
	  enable = true;
	  alsa.enable = true;
	  pulse.enable = true;
	  jack.enable = true;
 };
 security.rtkit.enable = true;

  system.stateVersion = "26.05";

}

