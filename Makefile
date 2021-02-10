IGNORED = Brewfile Makefile README.md vscode $(KITTY_CONF)
FILES = $(filter-out $(IGNORED),$(wildcard *))
DOTFILES = $(addprefix $(HOME)/.,$(FILES))
RELDIR = $(subst $(HOME)/,,$(shell pwd -L))
CONFIG_DIR = $(HOME)/.config

KITTY_CONF = kitty.conf
VSCODE_DIR = $(HOME)/Library/Application\ Support/Code/User

all: links test kitty vscode

.PHONY: links
links: $(DOTFILES)

$(HOME)/.%: %
	@ln -sv$(if $(FORCE),f) "$(RELDIR)/$<" "$@"

.PHONY: kitty
kitty: $(CONFIG_DIR)/kitty/$(KITTY_CONF)
$(CONFIG_DIR)/kitty/$(KITTY_CONF): $(KITTY_CONF)
	@mkdir -p "$$(dirname "$@")"
	@ln -sv$(if $(FORCE),f) "$(HOME)/$(RELDIR)/$<" "$@"

.PHONY: vscode vscode/extensions vscode-extra
vscode: $(VSCODE_DIR)/keybindings.json $(VSCODE_DIR)/settings.json vscode/extensions
$(VSCODE_DIR)/%.json: vscode/%.json
	@mkdir -p "$$(dirname "$@")"
	@ln -sv$(if $(FORCE),f) "$(HOME)/$(RELDIR)/$<" "$@"
vscode/extensions:
	@for ext in $$(code --list-extensions | comm -23 $@ -); do \
		code --install-extension "$$ext"; \
	done
vscode-extra:
	@code --list-extensions | comm -23 - vscode/extensions

.PHONY: test
test: UNLINKED = $(strip $(foreach f,$(FILES),$(shell test $(f) -ef $(HOME)/.$(f) || echo $(f))))
test:
	$(if $(UNLINKED),$(error unlinked files: $(UNLINKED)))

.PHONY: clean
clean:
	@find $$HOME -maxdepth 1 -type l -exec test ! -e {} \; -print -delete
