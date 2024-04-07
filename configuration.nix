# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  change-mac = pkgs.writeShellScript "change-mac" ''
    for card in "$@"; do
      tmp=$(mktemp)
      ${pkgs.macchanger}/bin/macchanger "$card" -s | grep -oP "[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[^ ]*" > "$tmp"
      mac1=$(cat "$tmp" | head -n 1)
      mac2=$(cat "$tmp" | tail -n 1)
      if [ "$mac1" = "$mac2" ]; then
        if [ "$(cat /sys/class/net/"$card"/operstate)" = "up" ]; then
          ${pkgs.iproute2}/bin/ip link set "$card" down &&
          ${pkgs.macchanger}/bin/macchanger -br "$card"
          ${pkgs.iproute2}/bin/ip link set "$card" up
        else
          ${pkgs.macchanger}/bin/macchanger -br "$card"
        fi
      fi
    done
  '';

  # Adds nixos-unstable packages
  # Make sure to add the unstable repo first
  pkgsUnstable = import <unstable> { config.allowUnfree = true; };

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  # Macchanger
  systemd.services.macchanger = {
    enable = true;
    description = "macchanger on multiple network cards";
    wants = [ "network-pre.target" ];
    before = [ "network-pre.target" ];
    bindsTo = [ "sys-subsystem-net-devices-wlp3s0.device" ];
    after = [ "sys-subsystem-net-devices-wlp3s0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${change-mac} wlp3s0 enp5s0 enp2s0f0";
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enables ntfs
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

#START volk USER CONFIG

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.volk = {};
  users.users.volk = {
    isNormalUser = true;
    description = "Volk";
    extraGroups = [ "networkmanager" "wheel" "volk" ];
    packages = with pkgs; [
      gcc
      go
	
      #python3
      (python3.withPackages(ps: with ps; [
        requests
      ]))

      git
      gnupg
      gpg-tui
      neofetch
      firefox
      btop
      brave
      flameshot
      vscode
      thunderbird
      leafpad
      gimp
      tilix
      pkgsUnstable.libvibrant
      
      # Addons
      cmatrix
      pkgsUnstable.mullvad-vpn
      #pkgsUnstable.discord
      #(pkgsUnstable.discord.override {
        #   withVencord = true;
      #})
      pkgsUnstable.vesktop
      element-desktop
      pkgsUnstable.planify
      ledger-live-desktop
      spotify
      steam
    ];
  };

  # Enables mullvad-vpn
  services.mullvad-vpn.enable = true;
  services.resolved.enable = true;

  # Enables steam
  programs.steam.enable = true;
  
  # Enables zsh for user volk
  users.users.volk.shell = pkgs.zsh;

#END volk USER CONFIG

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    ntfs3g
    vim
    wget
    whois
    tldr
    fwupd
    macchanger
    zsh
  ];

  # enable zsh
  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  #users.defaultUserShell = pkgs.zsh;

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
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
