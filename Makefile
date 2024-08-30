.DEFAULT_GOAL := all

bootstrap:
	xcode-select --install
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	/opt/homebrew/bin/brew bundle
	# TODO XXX
	# sudo puma-dev -setup
	# puma-dev -install

ssh-key:
	ssh-keygen -t ed25519 -a 100

all:
	stow --target=$$HOME --no-folding --restow src

clean:
	stow --verbose --target=$$HOME --no-folding --delete src
