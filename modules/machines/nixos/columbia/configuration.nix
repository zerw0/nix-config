{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  twaybladePkgs = inputs.twayblade.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  ghosttyPkg = twaybladePkgs.ghostty;
  retention = {
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = 6;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 4;
    TIMELINE_LIMIT_MONTHLY = 3;
    TIMELINE_LIMIT_YEARLY = 0;
    NUMBER_CLEANUP = true;
    NUMBER_LIMIT = 10;
  };
in
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  system.stateVersion = "26.05";
  nixpkgs.overlays = [ inputs.nur.overlays.default ];
  networking.hostName = "columbia";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  users.users.hdjenkov.extraGroups = [
    "networkmanager"
    "docker"
    "libvirtd"
  ];

  virtualisation.docker.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.tailscaleAuthKey.file = lib.mkForce "${inputs.secrets}/columbiaTailscaleAuthKey.age";
  age.secrets.forgejoAccessToken = {
    file = "${inputs.secrets}/forgejoAccessToken.age";
    owner = "hdjenkov";
    group = "hdjenkov";
  };
  age.secrets.columbiaBuilderSshKey.file = "${inputs.secrets}/columbiaBuilderSshKey.age";
  programs.ssh.extraConfig = builtins.readFile "${inputs.secrets}/columbia-builder-ssh.conf";
  programs.ssh.knownHosts.unraid-builder = {
    hostNames = [ "unraid-builder" ];
    publicKey = builtins.readFile "${inputs.secrets}/columbia-builder-hostkey.pub";
  };
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = "unraid-builder";
      protocol = "ssh-ng";
      sshUser = "root";
      sshKey = config.age.secrets.columbiaBuilderSshKey.path;
      systems = [ "x86_64-linux" ];
      maxJobs = 1;
      speedFactor = 4;
      supportedFeatures = [ "big-parallel" ];
    }
  ];
  modules.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscaleAuthKey.path;
  };
  services.tailscale.extraSetFlags = [ "--operator=hdjenkov" ];
  services.netbird.enable = true;
  services.flatpak = {
    enable = true;
    packages = [ "eu.betterbird.Betterbird" ];
  };
  programs.steam.enable = true;
  programs.localsend.enable = true;

  home-manager.users.hdjenkov = {
    imports = [
      ../../../dots/ghostty
      ../../../dots/vscodium
      ../../../dots/gruvbox
    ];
    dots.dev-tools.enable = true;
    dots.cloud-tools.enable = true;
    programs.ghostty.package = lib.mkForce (
      pkgs.symlinkJoin {
        name = "ghostty-radeon-${ghosttyPkg.version}";
        inherit (ghosttyPkg) version meta;
        paths = [ ghosttyPkg ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/ghostty" --set LIBGL_ALWAYS_SOFTWARE 1
          rm "$out/share/applications/com.mitchellh.ghostty.desktop"
          cp "${ghosttyPkg}/share/applications/com.mitchellh.ghostty.desktop" "$out/share/applications/"
          substituteInPlace "$out/share/applications/com.mitchellh.ghostty.desktop" \
            --replace-fail "Exec=ghostty " "Exec=$out/bin/ghostty "
        '';
      }
    );
    programs.ghostty.settings.font-size = 12;
    home.packages =
      with pkgs;
      [
        eza
        fd
        ffmpeg
        htop
        localsend
        ncdu
        ripgrep
        wget
        yt-dlp
        ansible
        (anydesk.overrideAttrs (old: {
          src = pkgs.fetchurl {
            inherit (old.src) url;
            hash = "sha256-zS5P2eyTHZY7cBW8mQ2Q6M0lXcx9VZZTtpG3Bb6u7IQ=";
          };
        }))
        bitwarden-desktop
        blender
        bottles
        calibre
        (chromium.override {
          commandLineArgs = "--use-angle=gl --disable-features=Vulkan --ozone-platform=x11";
        })
        codex
        element-desktop
        fladder
        haruna
        libreoffice
        mpv
        orca-slicer
        rustdesk-flutter
        remmina
        telegram-desktop
        transmission_4-qt
        trayscale
        vesktop
        viber
        nur.repos.Ev357.helium
      ]
      ++ [
        (inputs.twayblade.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          RUST_MIN_STACK = "67108864";
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ twaybladePkgs.rustPlatform.bindgenHook ];
          buildInputs = (old.buildInputs or [ ]) ++ [ twaybladePkgs.libva ];
          postFixup = (old.postFixup or "") + ''
            wrapProgram "$out/bin/twayblade" --prefix LD_LIBRARY_PATH : ${
              lib.makeLibraryPath [ twaybladePkgs.libva ]
            }
          '';
        }))
        inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    home.sessionVariables.FORGEJO_TOKEN_FILE = config.age.secrets.forgejoAccessToken.path;
    programs.zsh.initContent = lib.mkAfter ''
      forgejo-token() { cat "$FORGEJO_TOKEN_FILE"; }
    '';
    xdg.desktopEntries.helium = {
      name = "Helium";
      exec = "${lib.getExe pkgs.nur.repos.Ev357.helium} --use-angle=gl --disable-features=Vulkan --ozone-platform=x11 %U";
      icon = "helium";
      categories = [
        "Network"
        "WebBrowser"
      ];
    };
    xdg.configFile."baloofilerc".text = ''
      [Basic Settings]
      Indexing-Enabled=false
    '';
  };

  environment.systemPackages = with pkgs; [
    btrfs-progs
    docker-compose
    podman-compose
    pciutils
    usbutils
    libva-utils
  ];

  services.desktopManager.plasma6.enable = true;
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "radeon" ];
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";
  programs.kde-pim.enable = false;
  services.orca.enable = false;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    konsole
    khelpcenter
    krdp
    plasma-workspace-wallpapers
    plasma-keyboard
    qtvirtualkeyboard
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.libinput.enable = true;
  services.xserver.xkb.layout = "us,bg";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  services.snapper = {
    snapshotRootOnBoot = true;
    persistentTimer = true;
    configs = {
      root = retention // {
        SUBVOLUME = "/";
      };
      home = retention // {
        SUBVOLUME = "/home";
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /.snapshots 0750 root root -"
    "d /home/.snapshots 0750 root root -"
  ];
}
