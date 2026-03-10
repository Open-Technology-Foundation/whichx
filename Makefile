# Makefile - Install which
# BCS1212 compliant

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
DESTDIR ?=

.PHONY: all install uninstall check test help

all: help

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 which $(DESTDIR)$(BINDIR)/which
	install -d $(DESTDIR)$(MANDIR)
	install -m 644 which.1 $(DESTDIR)$(MANDIR)/which.1
	@if [ -z "$(DESTDIR)" ]; then $(MAKE) --no-print-directory check; fi

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/which
	rm -f $(DESTDIR)$(MANDIR)/which.1

check:
	@[ -x $(PREFIX)/bin/which ] \
	  && echo 'which: OK ($(PREFIX)/bin/which)' \
	  || echo 'which: NOT FOUND in $(PREFIX)/bin'

test:
	./tests/test_which.sh

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  test        Run test suite'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/whichx.git'
	@echo '  cd whichx && sudo make install'
