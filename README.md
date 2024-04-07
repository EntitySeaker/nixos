# System configuration

## Update the nixos system
- sudo nix-channel --list #Lists channels
- sudo nix-channel --update #Updates packages, not needed when --upgrade is specified for nixos-rebuild
- sudo nixos-rebuild dry-build #Lists outdated packages
- sudo nixos-rebuild switch --upgrade #Rebuilds and updates the system
- sudo nix-channel --rollback #Rolls back to the previous version incase the udpate broke things

## Audo update the nixos system
- system.autoUpgrade.channel = https://nixos.org/channels/nixos-19.09; #Specify the channel (optional)
- system.autoUpgrade.enable = true; #Enables automatic updates
- system.autoUpgrade.allowReboot = true; #Enables automatic reboots after kernel updates (optional)

## Export dconf configs
- dconf dump / #Lists the whole dconf config
- dconf dump /org/cinnamon/ > cinnamon-config #Writes cinnamon dconf config to a file
- dconf load /org/cinnamon/ < cinnamon-config #Loads cinnamon dconf config from a file
- Restart cinnamon with: Ctrl-Alt-Esc
- dconf dump /com/gexperts/Tilix/ > tilix-backup #Writes tilix dconf config to a file
- dconf load /com/gexperts/Tilix/ < tilix-backup #Loads tilix dconf config from a file

## Customization
In order to add new cursors for a user extract the cursor zip package inside ~/.config
Then restart the themes application and choose the custom cursor
The filemanager takes pictures, videos, documents etc from: ~/.config/user-dirs.dirs

## vibrant-cli
nix-shell -p cmake gnumake pkgs.xorg.libX11 pkgs.xorg.libXrandr #These packages are required to build
In order to build the nvdia compatibility needs to be removed

## Delete old generations
- sudo nix-env --list-generations --profile /nix/var/nix/profiles/system #Lists all generations
- sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system #Deletes all old generations
- nix-collect-garbage #Cleans up the system (removing links and such)