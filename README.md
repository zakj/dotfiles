# Configuring a new machine

Generate a new SSH key:

    ssh-keygen -t ed25519 -a 100

Install homebrew and formulae:

    xcode-select --install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle
    sudo puma-dev -setup
    puma-dev -install

Fix key repeat in vscode:

    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

## Sonoma

* System settings:
    * Desktop & Dock: Automatically hide and show the Dock
    * Desktop & Dock: Turn off "Show suggested and recent apps Dock"
    * Keyboard: Text Input: Turn off "Correct spelling automatically"
    * Keyboard: Text Input: Turn off "Capitalize words automatically"
    * Trackpad: Tap to click
    * General: Set Name to something reasonable
* Hammerspoon:
  * Launch Hammerspoon at login
  * Turn off "Show menu icon"
  * Enable Accessibility
* Messages: Turn off "Play sound effects"
* Raycast: Appearance: Hide Raycast icon in the menu bar
