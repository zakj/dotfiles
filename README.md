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

Generate a new SSH key:

    ssh-keygen -a 64 -t ed25519

On Sierra:

* System preferences:
    * General: Graphite
    * Dock: Automatically hide and show the Dock
    * Keyboard: Modifier Keys... Caps-Lock → Ctrl
    * Keyboard: Text: Uncheck "Correct spelling automatically"
    * Trackpad: Tap to click
    * Sharing: Computer Name
* iTerm
    * Load my color scheme
    * Set font to Menlo
* Messages: Uncheck "Play sound effects"
* Tweetbot: Uncheck "Show Menu Bar Icon"
* Dropbox: Uncheck "Show desktop notifications"
* Chrome: Check "Hide Notifications Icon" in Chrome menu
* Xee: Formats: Select all recommended
