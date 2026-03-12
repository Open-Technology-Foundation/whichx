# Makefile - Install which
# BCS1212 compliant

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1
DESTDIR ?=

.PHONY: all install uninstall check test test-posix test-compat test-all help

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

test-posix:
	/bin/sh ./tests/test_which_posix.sh

test-compat:
	./tests/test_compat.sh

test-all: test test-posix test-compat

help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@echo '  install     Install to $(PREFIX)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installation'
	@echo '  test        Run Bash test suite'
	@echo '  test-posix  Run POSIX test suite'
	@echo '  test-compat Run compatibility tests vs Debian legacy'
	@echo '  test-all    Run all test suites'
	@echo '  help        Show this message'
	@echo ''
	@echo 'Install from GitHub:'
	@echo '  git clone https://github.com/Open-Technology-Foundation/whichx.git'
	@echo '  cd whichx && sudo make install'
