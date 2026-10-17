{ config, lib, pkgs, spicetify-nix, ... }:

{
  home.username = "focarix";
  home.homeDirectory = "/home/focarix";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Shell Configuration (Bash)
  programs.bash = {
    enable = true;
    shellAliases = {
      sober = "flatpak run org.vinegarhq.Sober";
      sober-shader = "flatpak run --env=ENABLE_VKBASALT=1 org.vinegarhq.Sober";
      lg = "lazygit";
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons -l --group-directories-first";
      la = "eza --icons -a --group-directories-first";
    };
    initExtra = ''
      export PATH="$HOME/.local/bin:$HOME/.local/share/lerd/bin:$HOME/.opencode/bin:$HOME/.npm-global/bin:$PATH"

      # Jalankan fastfetch hanya pada sesi terminal interaktif
      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };

  # CLI Utilities
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    foot
    quickshell
    upscayl
    xdg-user-dirs
    swaybg
    libnotify
    vesktop
    easyeffects
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QS_ICON_THEME = "WhiteSur";
  };

  # GTK Theme, Icons, and Cursors
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "WhiteSur-Dark";
      package = pkgs.whitesur-gtk-theme;
    };
    iconTheme = {
      name = "WhiteSur";
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = {
      name = "WhiteSur-cursors";
      package = pkgs.whitesur-cursors;
      size = 24;
    };
    font = {
      name = "Inter";
      size = 11;
    };
  };

  # Dotfiles Configuration
  xdg.configFile."kitty".source = ../dotfiles/kitty;
  xdg.configFile."foot".source = ../dotfiles/foot;
  xdg.configFile."cava".source = ../dotfiles/cava;
  xdg.configFile."btop".source = ../dotfiles/btop;
  xdg.configFile."fastfetch".source = ../dotfiles/fastfetch;
  xdg.configFile."starship.toml".source = ../dotfiles/starship.toml;
  xdg.configFile."gtk-3.0/settings.ini".source = ../dotfiles/gtk-3.0/settings.ini;
  xdg.configFile."gtk-3.0/gtk.css".source = ../dotfiles/gtk-3.0/gtk.css;
  xdg.configFile."gtk-3.0/thunar.css".source = ../dotfiles/gtk-3.0/thunar.css;
  xdg.configFile."gtk-4.0/settings.ini".source = ../dotfiles/gtk-4.0/settings.ini;
  xdg.configFile."gtk-4.0/gtk.css".source = ../dotfiles/gtk-4.0/gtk.css;
  xdg.configFile."gtk-4.0/thunar.css".source = ../dotfiles/gtk-4.0/thunar.css;
  xdg.configFile."Code/User/settings.json".source = ../dotfiles/Code/User/settings.json;

  # Hyprland Config
  xdg.configFile."hypr".source = ../dotfiles/hypr;

  # Helper Executables in ~/.local/bin
  home.file.".local/bin/start-serpantinum.sh" = {
    source = ../dotfiles/bin/start-serpantinum.sh;
    executable = true;
  };
  home.file.".local/bin/apply_sddm_sync" = {
    source = ../dotfiles/bin/apply_sddm_sync;
    executable = true;
  };
  home.file.".local/bin/update_serpantinum" = {
    source = ../dotfiles/bin/update_serpantinum;
    executable = true;
  };

  # Activation hooks: Pastikan file writable, aset visual tersedia, & lock file bersih
  home.activation.setupSerpantinumAndAssets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # 1. Bersihkan file lock Chromium/Electron hanya jika aplikasinya TIDAK sedang aktif (mencegah tabrakan profil)
    if ! pgrep -x brave >/dev/null 2>&1; then
      $DRY_RUN_CMD rm -f "$HOME/.config/BraveSoftware/Brave-Browser/Singleton"* 2>/dev/null || true
    fi
    if ! pgrep -x msedge >/dev/null 2>&1; then
      $DRY_RUN_CMD rm -f "$HOME/.config/microsoft-edge/Singleton"* 2>/dev/null || true
    fi
    if ! pgrep -x chrome >/dev/null 2>&1; then
      $DRY_RUN_CMD rm -f "$HOME/.config/google-chrome/Singleton"* 2>/dev/null || true
    fi
    if ! pgrep -x code >/dev/null 2>&1; then
      $DRY_RUN_CMD rm -f "$HOME/.config/Code/Singleton"* 2>/dev/null || true
    fi
    if ! pgrep -x antigravity >/dev/null 2>&1; then
      $DRY_RUN_CMD rm -f "$HOME/.config/Antigravity/Singleton"* 2>/dev/null || true
    fi
    if ! pgrep -x spotify >/dev/null 2>&1; then
      $DRY_RUN_CMD rm -f "$HOME/.cache/spotify/Singleton"* 2>/dev/null || true
    fi

    # 2. Serpantinum settings (harus writable agar UI bisa update konfigurasi)
    $DRY_RUN_CMD mkdir -p $HOME/.config/serpantinum
    if [ ! -f $HOME/.config/serpantinum/settings.json ]; then
      $DRY_RUN_CMD cp ${../dotfiles/serpantinum/settings.json} $HOME/.config/serpantinum/settings.json
      $DRY_RUN_CMD chmod 644 $HOME/.config/serpantinum/settings.json
    fi

    # 3. Direktori Wallpapers & Profile Pictures
    $DRY_RUN_CMD mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Profile Pictures" "$HOME/.local/share/icons"
    if [ ! -f "$HOME/Pictures/Profile Pictures/The Fallen Angel.jpg" ]; then
      $DRY_RUN_CMD cp "${../assets/profile/the_fallen_angel.jpg}" "$HOME/Pictures/Profile Pictures/The Fallen Angel.jpg"
    fi
    if [ ! -f "$HOME/Pictures/Wallpapers/default_desktop.jpg" ]; then
      $DRY_RUN_CMD cp "${../assets/wallpapers/default_desktop.jpg}" "$HOME/Pictures/Wallpapers/default_desktop.jpg"
    fi

    # 4. Ikon Antigravity
    if [ -f "${../assets/icons/antigravity.png}" ]; then
      $DRY_RUN_CMD cp "${../assets/icons/antigravity.png}" "$HOME/.local/share/icons/antigravity.png"
    fi
  '';
}
