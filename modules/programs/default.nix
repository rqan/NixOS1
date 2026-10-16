{ config, lib, pkgs, inputs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Wrappers biner Antigravity: IDE (Teks Editor) dan Dashboard (Antigravity 2.0 AI)
  antigravityIdeWrapper = pkgs.writeShellScriptBin "antigravity-ide" ''
    IDE_DIR="$HOME/.local/opt/Antigravity-x64"
    if [ -x "$IDE_DIR/antigravity-ide" ]; then
      exec "$IDE_DIR/antigravity-ide" "$@"
    elif [ -x "$HOME/.local/bin/antigravity-ide" ]; then
      exec "$HOME/.local/bin/antigravity-ide" "$@"
    else
      echo "Error: Biner Antigravity IDE (Teks Editor) tidak ditemukan." >&2
      exit 1
    fi
  '';

  antigravityDashboardWrapper = pkgs.writeShellScriptBin "antigravity-dashboard" ''
    HUB_DIR="$HOME/.local/opt/Antigravity-Hub-x64"
    if [ -x "$HUB_DIR/antigravity" ]; then
      exec "$HUB_DIR/antigravity" "$@"
    elif [ -x "$HOME/.local/bin/antigravity-dashboard" ]; then
      exec "$HOME/.local/bin/antigravity-dashboard" "$@"
    elif [ -x "$HOME/.local/bin/antigravity-hub" ]; then
      exec "$HOME/.local/bin/antigravity-hub" "$@"
    else
      echo "Error: Biner Antigravity Dashboard tidak ditemukan." >&2
      exit 1
    fi
  '';

  antigravityWrapper = pkgs.writeShellScriptBin "antigravity" ''
    HUB_DIR="$HOME/.local/opt/Antigravity-Hub-x64"
    IDE_DIR="$HOME/.local/opt/Antigravity-x64"

    # Jika dipanggil dengan path file/folder, utamakan membuka di IDE (editor)
    if [ "$#" -gt 0 ]; then
      if [ -x "$IDE_DIR/antigravity-ide" ]; then
        exec "$IDE_DIR/antigravity-ide" "$@"
      fi
    fi

    # Jika tanpa argumen, utamakan Dashboard jika tersedia, fallback ke IDE
    if [ -x "$HUB_DIR/antigravity" ]; then
      exec "$HUB_DIR/antigravity" "$@"
    elif [ -x "$IDE_DIR/antigravity-ide" ]; then
      exec "$IDE_DIR/antigravity-ide" "$@"
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
    antigravityIdeWrapper
    antigravityDashboardWrapper

    # Custom Desktop Shortcuts (.desktop)
    (pkgs.makeDesktopItem {
      name = "github-desktop";
      desktopName = "GitHub Desktop";
      exec = "github-desktop %u";
      mimeTypes = [ "x-scheme-handler/x-github-client" ];
    })
    (pkgs.makeDesktopItem {
      name = "antigravity-ide";
      desktopName = "Antigravity GUI (Text Editor)";
      comment = "Google Antigravity IDE (Code Editor)";
      exec = "antigravity-ide %F";
      icon = "antigravity";
      categories = [ "Development" "IDE" "TextEditor" ];
      mimeTypes = [ "text/plain" "inode/directory" ];
    })
    (pkgs.makeDesktopItem {
      name = "antigravity-dashboard";
      desktopName = "Antigravity GUI (Dashboard)";
      comment = "Google Antigravity 2.0 (AI Agent Dashboard)";
      exec = "antigravity-dashboard";
      icon = "antigravity";
      categories = [ "Development" "ArtificialIntelligence" "Utility" ];
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
    pkgs.telegram-desktop

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
