{ config, lib, pkgs, inputs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Flatpak & Podman
  services.flatpak.enable = true;
  virtualisation.podman.enable = true;

  # Nix-LD for unpatched dynamic binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      glib
      gtk3
      nss
      nspr
      dbus
      atk
      at-spi2-atk
      cups
      expat
      libdrm
      mesa
      libxkbcommon
      pango
      cairo
      alsa-lib
      libGL
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libxcb
      libgbm
    ];
  };

  # Spicetify (Spotify Transparent Catppuccin Mocha)
  programs.spicetify = {
    enable = true;
    wayland = true;
    windowManagerPatch = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];
    theme = spicePkgs.themes.comfy // {
      additionalCss = ''
        .Root__main-view, 
        .Root__nav-bar, 
        .main-nowPlayingBar-container,
        .Root__top-container,
        .os-viewport {
            background-color: rgba(30, 30, 46, 0.4) !important;
            background-image: none !important;
        }
      '';
    };
    colorScheme = "catppuccin-mocha";
  };

  # Lerd helper symlink
  systemd.user.tmpfiles.rules = [
    "L %h/.local/bin/lerd - - - - /run/current-system/sw/bin/lerd"
  ];

  # System-wide packages
  environment.systemPackages = [
    # Custom desktop item
    (pkgs.makeDesktopItem {
      name = "github-desktop";
      desktopName = "GitHub Desktop";
      exec = "github-desktop %u";
      mimeTypes = [ "x-scheme-handler/x-github-client" ];
    })

    # Pengolah Foto & Video
    pkgs.kdePackages.kdenlive
    pkgs.gimp

    # Web Browser
    pkgs.brave
    pkgs.microsoft-edge

    # Pemrograman & Developer Tools
    pkgs.proton-vpn
    pkgs.git
    pkgs.github-desktop
    pkgs.neovim
    pkgs.android-studio
    pkgs.dotnet-sdk_8
    pkgs.nodejs
    pkgs.pnpm
    (pkgs.python3.withPackages (ps: with ps; [ evdev ]))
    (pkgs.dbeaver-bin.overrideAttrs (_finalAttrs: _previousAttrs: {
      version = "26.2.2";
      src = pkgs.fetchurl {
        url = "https://github.com/dbeaver/dbeaver/releases/download/26.2.2/dbeaver-ce-26.2.2-linux-x86_64.tar.gz";
        hash = "sha256-J7Oaeaaexw+flcbuO2hRT8x2d6zvkyh+jfjhPMUzhNU=";
      };
    }))
    pkgs.vscode-fhs
    pkgs.appimage-run

    # Media Player & Audio
    pkgs.mpv
    pkgs.imv
    pkgs.amberol
    pkgs.cmus
    pkgs.pavucontrol
    pkgs.playerctl
    pkgs.pulseaudio

    # File Manager & System GUI Utilities
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.ark
    pkgs.unzip
    pkgs.udiskie
    pkgs.kitty

    # Graphics & Gaming
    pkgs.vulkan-tools
    pkgs.mesa-demos
    pkgs.vkbasalt

    # Tema, Cursor, & Ikon
    pkgs.whitesur-gtk-theme
    pkgs.whitesur-cursors
    pkgs.papirus-icon-theme

    # CLI Utils & Terminal Rice
    pkgs.fastfetch
    pkgs.btop
    pkgs.tree
    pkgs.tty-clock
    pkgs.lavat
    pkgs.cava
    pkgs.pipes
    pkgs.cmatrix
    pkgs.sptlrx
  ];
}
