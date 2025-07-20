# Configuring a new machine

Get a copy of this repository and install mise. 
Because git is not included on a clean install, we have to download a tarball.

```
curl -L https://github.com/zakj/dotfiles/archive/refs/heads/main.tar.gz | tar xzf -
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
```

Bootstrap everything else with mise:

```
mise run bootstrap
mise run stow
```

## Settings

System settings are handled by `mise bootstrap`, but there are a few other changes to make by hand:

* Hammerspoon:
  * Launch Hammerspoon at login
  * Turn off "Show menu icon"
  * Enable Accessibility
* Messages: Turn off "Play sound effects"
* Raycast: Appearance: Hide Raycast icon in the menu bar
