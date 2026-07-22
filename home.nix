{ config, pkgs, ... }:

{
	home.username = "ahmed";
	home.homeDirectory = "/home/ahmed";
	home.stateVersion = "26.05";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use nixos, btw";
		};
	};
	home.packages = with pkgs; [
		vscode
		baobab
		copyq
		papirus-icon-theme
		adwaita-icon-theme
		gnome-themes-extra
		gsettings-desktop-schemas
		gedit
		dconf
		glib
		catppuccin-gtk	
		polybar
		rofi
		picom
		copyq
		feh
		flameshot
		xset
		xmodmap
		xrandr
		brightnessctl
		playerctl
		yad
		networkmanagerapplet
		dex
		betterlockscreen
		fastfetch
		pulseaudio
	];
	
	programs.git = {
	  enable = true;

	  userName = "Ahmed Ayman";
	  userEmail = "ahmed.aaaeg@gmail.com";
	};
	
	dconf.enable = true;
	
	gtk = {
		enable = true;

		theme = {
			name = "Catppuccin-Mocha-Standard";
			package = pkgs.catppuccin-gtk;
		};
		
		iconTheme = {
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};

		cursorTheme = {
			name = "Adwaita";
			package = pkgs.adwaita-icon-theme;
		};
	};
	
	dconf.settings = {
	    "org/gnome/desktop/interface" = {
		      gtk-theme = "Catppuccin-Mocha-Standard";
		      icon-theme = "Papirus-Dark";
		      cursor-theme = "Adwaita";
		      color-scheme = "prefer-dark";
	    };
	};
	
	gtk.gtk4.extraConfig = {
	  gtk-theme-name = "Catppuccin-Mocha-Standard";
	  gtk-icon-theme-name = "Papirus-Dark";
	  gtk-cursor-theme-name = "Adwaita";
	};
	
	xdg.configFile = {
	  "i3/config".source = ./dotfiles/i3/config;

	  "polybar/config.ini".source = ./dotfiles/polybar/config.ini;

	  "polybar/launch.sh".source = ./dotfiles/polybar/launch.sh;

	  "polybar/scripts".source = ./dotfiles/polybar/scripts;

	  "rofi/config.rasi".source = ./dotfiles/rofi/config.rasi;

	  "picom/picom.conf".source = ./dotfiles/picom/picom.conf;
	};
	
	xdg.configFile."rofi" = {
	    source = ./dotfiles/rofi;
	    recursive = true;
	};
	
	home.file.".local/bin/mic-toggle.sh" = {
	  source = ./dotfiles/scripts/mic-toggle.sh;
	  executable = true;
	};
	

	services.xsettingsd.enable = true;
}
