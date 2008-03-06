.PHONY: mail
mail: mutt,aliases

mutt,aliases: aliases.in ../workstation/contacts
	{ echo '# WARNING: This file was auto-generated. Do not edit!'; \
	./mkaliases <../workstation/contacts; \
	cat aliases.in; } >$@
