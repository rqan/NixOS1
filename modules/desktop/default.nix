{ config, lib, pkgs, inputs, serpantinum, silentSDDM, ... }:

let
  patchedSilent = pkgs.stdenv.mkDerivation {
    name = "silent-patched";
    src = config.programs.silentSDDM.package';
    nativeBuildInputs = [ pkgs.perl ];
    installPhase = ''
      mkdir -p $out/share/sddm/themes/silent-patched
      cp -r $src/share/sddm/themes/silent/* $out/share/sddm/themes/silent-patched/
      
      chmod -R +w $out/share/sddm/themes/silent-patched
      
      perl -0777 -pi -e 's/property bool isVideo: \{.*?\}/property bool isVideo: {\n                var xhr = new XMLHttpRequest();\n                xhr.open("GET", "file:\/\/\/var\/lib\/sddm-wallpaper\/wallpaper_type", false);\n                try { xhr.send(); } catch(e) {}\n                if (xhr.status === 200 || xhr.status === 0) {\n                    return xhr.responseText.trim() === "video";\n                }\n                return false;\n            }/s' $out/share/sddm/themes/silent-patched/Main.qml

      perl -pi -e 's|source: !isVideo \? "backgrounds/" \+ tsource : ""|source: !isVideo ? "file:///var/lib/sddm-wallpaper/current_wallpaper" : ""|g' $out/share/sddm/themes/silent-patched/Main.qml
      perl -pi -e 's|backgroundVideo\.source = Qt\.resolvedUrl\("backgrounds/" \+ tsource\)|backgroundVideo.source = "file:///var/lib/sddm-wallpaper/current_wallpaper"|g' $out/share/sddm/themes/silent-patched/Main.qml
      
      sed -i 's/Name=silent/Name=silent-patched/' $out/share/sddm/themes/silent-patched/metadata.desktop
    '';
  };
in
{
  # Display Manager: SDDM Wayland with video wallpaper support
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = lib.mkForce true;
    theme = lib.mkForce "silent-patched";
    settings.General.GreeterEnvironment = lib.mkForce "QML2_IMPORT_PATH=/run/current-system/sw/share/sddm/themes/silent-patched/components/,QT_IM_MODULE=qtvirtualkeyboard";
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  # SDDM Theme & Shell
  programs.silentSDDM = {
    enable = true;
    theme = "rei";
  };

  # Serpantinum Shell
  programs.serpantinum.enable = true;

  # Hyprland Compositor
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Graphics & Hardware Acceleration
  hardware.graphics.enable = true;

  # XDG Portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Environment Variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    VK_LAYER_PATH = "${pkgs.vkbasalt}/share/vulkan/explicit_layer.d";
    QS_ICON_THEME = "WhiteSur";
  };

  # Tmpfiles rule for SDDM dynamic wallpaper storage
  systemd.tmpfiles.rules = [
    "d /var/lib/sddm-wallpaper 0755 focarix users"
  ];

  # Video recording support
  programs.gpu-screen-recorder.enable = true;

  # Desktop Environment Packages & Tools
  environment.systemPackages = [
    patchedSilent
    serpantinum.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.quickshell
    pkgs.matugen
    pkgs.qt6.qtwayland
    pkgs.brightnessctl
    pkgs.libnotify
    pkgs.polkit_gnome
    pkgs.seahorse
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.swaybg
    pkgs.wf-recorder
    pkgs.ffmpeg
    pkgs.inotify-tools
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    font-awesome
    material-symbols
  ];
}
