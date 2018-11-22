# Configuring a new machine

Set login shell:

    chsh -s $(which zsh)

Install homebrew and formulae:

    xcode-select --install
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew bundle
    sudo puma-dev -d test -setup
    puma-dev -d test -install

Set up vim plugins:

    vim +PlugInstall +qall

Fix key repeat in vscode:

    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

Generate a new SSH key:

    ssh-keygen -a 64 -t ed25519

On Mojave:

* System preferences:
    * General: Graphite
    * Dock: Automatically hide and show the Dock
    * Dock: Uncheck "Show recent applications in Dock"
    * Keyboard: Modifier Keys... Caps-Lock → Ctrl
    * Keyboard: Text: Uncheck "Correct spelling automatically"
    * Keyboard: Text: Uncheck "Capitalize words automatically"
    * Notifications: Do Not Disturb: Check "When the display is sleeping"
    * Trackpad: Tap to click
    * Sharing: Computer Name
* iTerm
    * Load my color scheme
    * Set font to Menlo
* Messages: Uncheck "Play sound effects"
* Tweetbot: Uncheck "Show Menu Bar Icon"
* Xee: Formats: Select all recommended
