IGNORED = Brewfile Makefile README.md
FILES = $(filter-out $(IGNORED),$(wildcard *))
DOTFILES = $(addprefix $(HOME)/.,$(FILES))
RELDIR = $(subst $(HOME)/,,$(shell pwd -L))

all: links test

links: $(DOTFILES)

$(HOME)/.%: %
	@ln -sv$(if $(FORCE),f) "$(RELDIR)/$<" "$@"

.PHONY: test
test: UNLINKED = $(strip $(foreach f,$(FILES),$(shell test $(f) -ef $(HOME)/.$(f) || echo $(f))))
test:
	$(if $(UNLINKED),$(error unlinked files: $(UNLINKED)))

clean:
	@find $$HOME -maxdepth 1 -type l -exec test ! -e {} \; -delete
