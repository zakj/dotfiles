IGNORED = Brewfile Makefile README.md config.fish kitty.conf nvim.lua rg.conf starship.toml vscode zed
FILES = $(filter-out $(IGNORED),$(wildcard *))
DOTFILES = $(addprefix $(HOME)/.,$(FILES))
RELDIR = $(subst $(HOME)/,,$(shell pwd -L))
CONFIG_DIR = $(HOME)/.config

define MAKE_LINK
@mkdir -p "$$(dirname "$@")"
@ln -sv$(if $(FORCE),f) "$(HOME)/$(RELDIR)/$<" "$@"
endef

.PHONY: all links test fish kitty nvim starship vscode zed
all: links test fish kitty nvim starship vscode zed

links: $(DOTFILES)

$(HOME)/.%: %
	@ln -sv$(if $(FORCE),f) "$(RELDIR)/$<" "$@"

fish: $(CONFIG_DIR)/fish/config.fish
$(CONFIG_DIR)/fish/config.fish: config.fish
	$(MAKE_LINK)

kitty: $(CONFIG_DIR)/kitty/kitty.conf
$(CONFIG_DIR)/kitty/kitty.conf: kitty.conf
	$(MAKE_LINK)

nvim: $(CONFIG_DIR)/nvim/init.lua
$(CONFIG_DIR)/nvim/init.lua: nvim.lua
	$(MAKE_LINK)

starship: $(CONFIG_DIR)/starship.toml
$(CONFIG_DIR)/starship.toml: starship.toml
	$(MAKE_LINK)

.PHONY: vscode/extensions vscode-extra
VSCODE_DIR = $(HOME)/Library/Application\ Support/Code/User
vscode: $(VSCODE_DIR)/keybindings.json $(VSCODE_DIR)/settings.json vscode/extensions
$(VSCODE_DIR)/%.json: vscode/%.json
	$(MAKE_LINK)
vscode/extensions:
	@for ext in $$(code --list-extensions | comm -23 $@ -); do \
		code --install-extension "$$ext"; \
	done
vscode-extra:
	@code --list-extensions | comm -23 - vscode/extensions

zed: $(CONFIG_DIR)/zed/settings.json $(CONFIG_DIR)/zed/keymap.json $(CONFIG_DIR)/zed/themes/mourning.json
$(CONFIG_DIR)/zed/settings.json: zed/settings.json
	$(MAKE_LINK)
$(CONFIG_DIR)/zed/keymap.json: zed/keymap.json
	$(MAKE_LINK)
$(CONFIG_DIR)/zed/themes/mourning.json: zed/mourning.json
	$(MAKE_LINK)

test: UNLINKED = $(strip $(foreach f,$(FILES),$(shell test $(f) -ef $(HOME)/.$(f) || echo $(f))))
test:
	$(if $(UNLINKED),$(error unlinked files: $(UNLINKED)))

.PHONY: clean
clean:
	@find $$HOME -maxdepth 1 -type l -exec test ! -e {} \; -print -delete
