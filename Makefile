IGNORED = Brewfile Makefile README.md $(VSCODE_EXT) $(VSCODE_SRC)
FILES = $(filter-out $(IGNORED),$(wildcard *))
DOTFILES = $(addprefix $(HOME)/.,$(FILES))
RELDIR = $(subst $(HOME)/,,$(shell pwd -L))
VSCODE_SRC = vscode.json
VSCODE_DST = $(HOME)/Library/Application\ Support/Code/User/settings.json
VSCODE_EXT = vscode.ext

all: links test vscode

.PHONY: links
links: $(DOTFILES)

$(HOME)/.%: %
	@ln -sv$(if $(FORCE),f) "$(RELDIR)/$<" "$@"

.PHONY: vscode vscode-ext
vscode: $(VSCODE_DST) vscode-ext
vscode-ext: $(VSCODE_EXT)
	@for ext in $$(code --list-extensions | comm -23 $< -); do \
		code --install-extension "$$ext"; \
	done

$(VSCODE_DST): $(VSCODE_SRC)
	@ln -sv$(if $(FORCE),f) "$(HOME)/$(RELDIR)/$<" "$@"

.PHONY: test
test: UNLINKED = $(strip $(foreach f,$(FILES),$(shell test $(f) -ef $(HOME)/.$(f) || echo $(f))))
test:
	$(if $(UNLINKED),$(error unlinked files: $(UNLINKED)))

.PHONY: clean
clean:
	@find $$HOME -maxdepth 1 -type l -exec test ! -e {} \; -print -delete
