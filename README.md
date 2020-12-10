# Configuring a new machine

Install homebrew and formulae:

    xcode-select --install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle
    sudo puma-dev -setup
    puma-dev -install

Set up vim plugins:

    vim +PlugInstall +qall

Fix key repeat in vscode:

    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

Generate a new SSH key:

    ssh-keygen -t ed25519 -a 100

## Big Sur

* System preferences:
    * General: Graphite
    * Dock: Automatically hide and show the Dock
    * Dock: Uncheck "Show recent applications in Dock"
    * Keyboard: Modifier Keys... Caps-Lock → Ctrl
    * Keyboard: Text: Uncheck "Correct spelling automatically"
    * Keyboard: Text: Uncheck "Capitalize words automatically"
    * Trackpad: Tap to click
    * Sharing: Computer Name
* Messages: Uncheck "Play sound effects"
* Tweetbot: Uncheck "Show Menu Bar Icon"
* Xee: Formats: Select all recommended
