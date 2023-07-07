# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

# Sets varible to be used to setup unstable channel packages installs
let
  unstableTarball = 
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz}/nixos")
    ] ++ lib.optional (builtins.pathExists ./secrets.nix) ./secrets.nix; # Includes extra configurations that should not be shared

  # Bootloader.
  boot = {
    kernel.sysctl = { "vm.swappiness" = 10;};
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback # OBS Virtual Webcam requirement	
    ];
    kernelModules = [
      "sg" # MakeMKV detect optical drives requirement
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true; # Steam requirement
      extraPackages = with pkgs; [
        libva
        libvdpau-va-gl
        vaapiVdpau
      ];
      extraPackages32 = with pkgs.driversi686Linux; [
        vaapiVdpau
      ];
    };
    pulseaudio.enable = false;
    steam-hardware.enable = true; # Steam Control requirement
  };

  systemd = {

    # Systemd Timeout changed to 10 seconds
  	extraConfig = ''
  	  DefaultTimeoutStopSec=10
  	'';
  };

  networking = {
    firewall = {
    	enable = true;
        allowedTCPPorts = [ 
          24070 # Steam Local Game Transfer
        ];
        allowedTCPPortRanges = [

          # Steam games
          {
          	from = 27015;
          	to = 27050;
          }
        ];
        allowedUDPPorts = [
          3478 # Steam
        ];
        allowedUDPPortRanges = [

          # Steam
          {
            from = 4379;
            to = 4380;
          }

          # Steam games
          {
          	from = 27000;
          	to = 27100;
          }
        ];
    };
    networkmanager.enable = true;

    # nftables replaces iptables
    nftables = {
      enable = true;
    };
    hostName = "console";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services = {
    dbus.enable = true;
    flatpak.enable = true;
    xserver = {
      enable = true;
      displayManager = {
        sddm = {
          enable = true;
          settings.Wayland.SessionDir = "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions"; # Enables Wayland session
        };
        defaultSession = "plasmawayland"; # Defaults to the Wayland session
      };
      desktopManager.plasma5 = {
        enable = true; # Enables KDE Plasma
      };
      layout = "us";
      xkbVariant = "";
    };

    # Enable sound with pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    printing.enable = false; # Disable printing
  };

  # Enable sound with pipewire.
  sound.enable = true;

  # Enable policy kit
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # Enable xdg portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
    xdgOpenUsePortal = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;
    users.dmelzak = {
      description = "Daniel Melzak";
      isNormalUser = true;
      extraGroups = [ 
        "audio"
        "cdrom"
        "disk"
        "input"
        "kvm"
        "libvirtd"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };

  home-manager = {
    users.dmelzak = { pkgs, ... }: {
      home = {
        stateVersion = "23.05";
        packages = with pkgs; [
          bitwarden
          discord
          freac
          jellyfin-media-player
          kate
          kdenlive
          picard
          plasma-browser-integration
          telegram-desktop
          vivaldi
          vivaldi-ffmpeg-codecs
          #games and tools
          duckstation
          pcsx2
          ppsspp-qt
          protontricks
          protonup-qt
        ];
        file = {
          ".config/kdedefaults/kdeglobals".source = home-manager/dmelzak/.config/kdedefaults/kdeglobals;
          ".config/baloofilerc".source = home-manager/dmelzak/.config/baloofilerc;
          ".config/dolphinrc".source = home-manager/dmelzak/.config/dolphinrc;
          ".config/kactivitymanagerd-statsrc".source = home-manager/dmelzak/.config/kactivitymanagerd-statsrc;
          ".config/kactivitymanagerdrc".source = home-manager/dmelzak/.config/kactivitymanagerdrc;
          ".config/kcminputrc".source = home-manager/dmelzak/.config/kcminputrc;
          ".config/kservicemenurc".source = home-manager/dmelzak/.config/kservicemenurc;
          ".config/powermanagementprofilesrc".source = home-manager/dmelzak/.config/powermanagementprofilesrc;
          ".local/share/applications/steam.desktop".source = home-manager/dmelzak/.local/share/applications/steam.desktop;
          ".local/share/dolphin/view_properties/global/.directory".source = home-manager/dmelzak/.local/share/dolphin/view_properties/global/.directory;
          ".local/share/konsole/Fish.profile".source = home-manager/dmelzak/.local/share/konsole/Fish.profile;
        };
      };
      programs = {
        git = {
          enable = true;
          userName = "TeamLinux01";
          userEmail = "43735175+TeamLinux01@users.noreply.github.com";
          signing = {
            key = "DD0331E0EE9D6C49";
            signByDefault = true;
          };
          extraConfig = {
            init = {
              defaultBranch = "main";
            };
          };
        };
        home-manager.enable = true;
        mangohud.enable = true;

        # Install OBS Studio with Wayland capture support
        obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            obs-gstreamer
            obs-pipewire-audio-capture
            obs-vaapi
            obs-vkcapture
          ];
        };
      };
      nixpkgs.config.allowUnfree = true;
    };
  };

  programs = {
    chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "ponfpcnoihfmfllpaingbgckeeldkhle" # Enhancer for YouTube
      	"ecanpcehffngcegjmadlcijfolapggal" # IPvFoo
      	"cimiefiiaegbelhefglklhhakcgmhkai" # Plasma Intergration
      	"cjpalhdlnbpafiamejdnhcphjbkeiagm" # UBlock Origin
      ];
    };
    fish.enable = true;
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    kdeconnect.enable = true;
    partition-manager.enable = true; # Install KDE Partition Manager

    # Install Steam
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };

  # Sets up system to be able to pull from unstable channel of packages
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #core system utilities
    appimage-run
    fwupd
    gnupg
    iotop
    iperf
    libsForQt5.kcalc
    libsForQt5.plasma-browser-integration
    libsForQt5.polkit-qt
    libsForQt5.polkit-kde-agent
    libportal
    libportal-qt5
    micro
    nixos-generators
    polkit
    pciutils
    solaar
    system76-keyboard-configurator
    tldr
    wl-clipboard # micro using external clipboard on Wayland requirement
    #display system utilities
    clinfo
    glxinfo
    handbrake
    libsForQt5.phonon-backend-vlc
    libva-utils
    makemkv
    mkvtoolnix
    mkvtoolnix-cli
    vlc
    vulkan-tools
    wayland-utils
    #file system utilities
    bchunk
    desktop-file-utils
    dua
    filezilla
    git
    gzip
    inotify-tools
    libarchive
    libsForQt5.kdeconnect-kde
    libsForQt5.kgpg
    libsForQt5.plasma-vault
    libsForQt5.quazip
    libzip
    p7zip
    partition-manager
    rar
    rclone
    tree
    unzip
    ventoy-full
    wget
    zip
    zstd
    #game utilities
    gamemode
    gamescope
    mame-tools
    unstable.ludusavi
  ];

  # NixOS Garbage Colletion
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  virtualisation.libvirtd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    copySystemConfiguration = true;
    stateVersion = "23.05";

    # Sets up Automatic Upgrades
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      channel = "https://nixos.org/channels/nixos-23.05";
    };
  };

}
