# System configuration
`#` = run as root<br>
`$` = run as user

## Update the nixos system
- `# nix-channel --list` #Lists channels
- `# nix-channel --update` #Fetches packages from the repositories
- `# nixos-rebuild switch` #Rebuilds the system
- `# nixos-rebuild switch --upgrade` #Rebuilds and updates the system
- `# nix-channel --rollback` #Rolls back to the previous version incase the update broke things

## Audo update the nixos system
- `system.autoUpgrade.channel = https://nixos.org/channels/nixos-19.09;` #Specify the channel (optional)
- `system.autoUpgrade.enable = true;` #Enables automatic updates
- `system.autoUpgrade.allowReboot = true;` #Enables automatic reboots after kernel updates (optional)

## Export dconf configs
- `$ dconf dump /` #Lists the whole dconf config
- `$ dconf dump /org/cinnamon/ > cinnamon-config` #Writes cinnamon dconf config to a file
- `$ dconf load /org/cinnamon/ < cinnamon-config` #Loads cinnamon dconf config from a file
- Restart cinnamon with: Ctrl-Alt-Esc
- `$ dconf dump /com/gexperts/Tilix/ > tilix-backup` #Writes tilix dconf config to a file
- `$ dconf load /com/gexperts/Tilix/ < tilix-backup` #Loads tilix dconf config from a file

## Customization
In order to add new cursors for a user extract the cursor zip package inside `~/.config`<br>
Then restart the themes application and choose the custom cursor<br>
The filemanager takes pictures, videos, documents etc from: `~/.config/user-dirs.dirs`

## Delete old generations
- `# nix-env --list-generations --profile /nix/var/nix/profiles/system` #Lists all generations
- `# nix-env --delete-generations old --profile /nix/var/nix/profiles/system` #Deletes all old generations
- `$ nix-collect-garbage` #Cleans up the system (removing links and such)