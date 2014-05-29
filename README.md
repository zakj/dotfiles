Install homebrew and formulae:

    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew bundle

Set up vim plugins:

    mkdir -p ~/.vim/autoload
    curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim
    vim +PlugInstall +qall
    (cd ~/.vim/plugged/Command-T && /usr/bin/rake make)

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
