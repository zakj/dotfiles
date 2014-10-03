Install homebrew and formulae:

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew bundle

Set up vim plugins:

    mkdir -p ~/.vim/autoload
    curl -fLo ~/.vim/autoload/plug.vim \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
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
* Xee
