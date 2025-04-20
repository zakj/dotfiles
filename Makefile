.DEFAULT_GOAL := all
.PHONY: bootstrap ssh-key lsp all clean
BREW := /opt/homebrew/bin

bootstrap:
	test -d $(BREW) || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	$(BREW)/brew bundle
	if ! grep -q $(BREW)/fish /etc/shells; then \
		echo $(BREW)/fish | sudo tee -a /etc/shells; \
		chsh -s $(BREW)/fish; \
	fi
	sudo $(BREW)/puma-dev -setup
	$(BREW)/puma-dev -install

ssh-key: $(HOME)/.ssh/id_ed25519
$(HOME)/.ssh/id_ed25519:
	ssh-keygen -t ed25519 -a 100

lsp:
	$(BREW)/brew bundle --file=Brewfile.lsp
	# install prettier plugins in local packages: prettier-plugin-astro prettier-plugin-svelte prettier-plugin-vue
	npm install --global --no-fund @astrojs/language-server svelte-language-server

all:
	$(BREW)/stow --target=$$HOME --dotfiles --no-folding --restow src

clean:
	$(BREW)/stow --target=$$HOME --dotfiles --no-folding --delete src
