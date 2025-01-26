.DEFAULT_GOAL := all
.PHONY: bootstrap ssh-key all clean
BREW := /opt/homebrew/bin

bootstrap:
	test -d $(BREW) || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	$(BREW)/brew bundle --no-lock
	if ! grep -q $(BREW)/fish /etc/shells; then \
		echo $(BREW)/fish | sudo tee -a /etc/shells; \
		chsh -s $(BREW)/fish; \
	fi
	sudo $(BREW)/puma-dev -setup
	$(BREW)/puma-dev -install

ssh-key: $(HOME)/.ssh/id_ed25519
$(HOME)/.ssh/id_ed25519:
	ssh-keygen -t ed25519 -a 100

all:
	$(BREW)/stow --target=$$HOME --dotfiles --no-folding --restow src

clean:
	$(BREW)/stow --target=$$HOME --dotfiles --no-folding --delete src
