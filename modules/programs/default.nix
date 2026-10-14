{ config, lib, pkgs, inputs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Wrapper biner Antigravity yang cerdas: mendeteksi instalasi lokal atau mengunduhnya otomatis
  antigravityWrapper = pkgs.writeShellScriptBin "antigravity" ''
    OPT_DIR="$HOME/.local/opt/Antigravity-x64"
    if [ ! -d "$OPT_DIR" ]; then
      if [ -f "$HOME/GitHub/NixOS/scripts/install-antigravity.sh" ]; then
        echo "==> Antigravity IDE belum terpasang. Menjalankan installer otomatis..." >&2
        bash "$HOME/GitHub/NixOS/scripts/install-antigravity.sh"
      fi
    fi

    if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
      if [ -x "$OPT_DIR/bin/antigravity-ide" ]; then
        exec "$OPT_DIR/bin/antigravity-ide" "$@"
      fi
    fi

    if [ -x "$OPT_DIR/antigravity" ]; then
      exec "$OPT_DIR/antigravity" "$@"
    elif [ -x "$OPT_DIR/antigravity-ide" ]; then
      exec "$OPT_DIR/antigravity-ide" "$@"
    elif [ -x "$HOME/.local/bin/antigravity" ]; then
      exec "$HOME/.local/bin/antigravity" "$@"
    else
      echo "Error: Biner Antigravity tidak ditemukan." >&2
      exit 1
    fi
  '';
in
{
  # Flatpak & Podman
  services.flatpak.enable = true;
  virtualisation.podman.enable = true;

  # Gamescope for gaming and vkBasalt shaders
  programs.gamescope.enable = true;

  # Nix-LD for unpatched dynamic binaries (Antigravity IDE, Electron, custom binaries)
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
      at-spi2-core
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
      systemd
      libnotify
      udev
      vulkan-loader
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
    # Custom Wrappers
    antigravityWrapper

    # Custom Desktop Shortcuts (.desktop)
    (pkgs.makeDesktopItem {
      name = "github-desktop";
      desktopName = "GitHub Desktop";
      exec = "github-desktop %u";
      mimeTypes = [ "x-scheme-handler/x-github-client" ];
    })
    (pkgs.makeDesktopItem {
      name = "sober-shader";
      desktopName = "Roblox (Sober + Shader & Gamescope)";
      comment = "Play Roblox with vkBasalt and Gamescope";
      exec = "env ENABLE_VKBASALT=1 gamescope -W 1920 -H 1080 -r 60 -F fsr -- flatpak run org.vinegarhq.Sober";
      icon = "org.vinegarhq.Sober";
      categories = [ "Game" ];
    })
    (pkgs.makeDesktopItem {
      name = "antigravity";
      desktopName = "Antigravity";
      comment = "Google Antigravity IDE";
      exec = "antigravity %F";
      icon = "antigravity";
      categories = [ "Development" "IDE" "TextEditor" ];
      mimeTypes = [ "text/plain" "inode/directory" ];
    })
    (pkgs.makeDesktopItem {
      name = "lerd";
      desktopName = "Lerd";
      genericName = "Local PHP development environment";
      comment = "Bring the environment up, then open the Lerd dashboard";
      exec = "lerd dashboard --splash";
      icon = "lerd";
      categories = [ "Development" ];
    })

    # Pengolah Foto & Video
    pkgs.kdePackages.kdenlive
    pkgs.gimp

    # Web Browser
    pkgs.brave
    pkgs.microsoft-edge

    # Komunikasi
    pkgs.vesktop

    # Pemrograman & Developer Tools
    pkgs.proton-vpn
    pkgs.git
    pkgs.github-desktop
    pkgs.neovim
    pkgs.android-studio
    pkgs.dotnet-sdk_8
    pkgs.nodejs
    pkgs.pnpm
    pkgs.php
    pkgs.phpPackages.composer
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
    pkgs.easyeffects
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
    pkgs.gamescope

    # Tema, Cursor, & Ikon
    pkgs.whitesur-gtk-theme
    pkgs.whitesur-icon-theme
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
    pkgs.cliphist
    pkgs.jq
    pkgs.eza
    pkgs.zoxide
    pkgs.direnv
    pkgs.lazygit
  ];
}
