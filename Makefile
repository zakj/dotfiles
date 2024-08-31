.DEFAULT_GOAL := all
BREW := /opt/homebrew/bin

bootstrap:
	xcode-select --install
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	$(BREW)/brew bundle --no-lock
	grep -q $(BREW)/fish /etc/shells || {echo $(BREW)/fish | sudo tee -a /etc/shells}
	chsh -s $(BREW)/fish
	sudo $(BREW)/puma-dev -setup
	$(BREW)/puma-dev -install

ssh-key:
	ssh-keygen -t ed25519 -a 100

all:
	stow --target=$$HOME --dotfiles --no-folding --restow src

clean:
	stow --target=$$HOME --dotfiles --no-folding --delete src
