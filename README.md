# Configuring a new machine

Set login shell:

    chsh -s $(which zsh)

Install homebrew and formulae:

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    sh Brewfile

Set up vim plugins:

    vim +PlugInstall +qall

Install App Store applications:

* 1Password
* Acorn
* Fantastical
* HTTP Client
* Lingo
* Marked
* Soulver
* The Unarchiver
* Tweetbot
* Xcode

On Yosemite:

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
* AppCleaner: Enable SmartDelete
* Chrome: Check "Hide Notifications Icon" in Chrome menu
* Xee: Formats: Select all recommended
