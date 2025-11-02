# Makefile for whichx
# Install whichx and create which symlink

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1
SCRIPT = whichx
SYMLINK = which
MANPAGE = whichx.1

.PHONY: all help install uninstall test

all: help

help:
	@echo "whichx Makefile targets:"
	@echo "  make install    - Install whichx, manpage, and create which symlink"
	@echo "  make uninstall  - Remove whichx, manpage, and which symlink"
	@echo "  make test       - Run shellcheck validation"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX=$(PREFIX)  - Installation prefix (default: /usr/local)"

install:
	@echo "Installing $(SCRIPT) to $(BINDIR)..."
	install -d $(BINDIR)
	install -m 755 $(SCRIPT) $(BINDIR)/$(SCRIPT)
	@echo "Creating symlink $(BINDIR)/$(SYMLINK) -> $(SCRIPT)..."
	ln -sf $(SCRIPT) $(BINDIR)/$(SYMLINK)
	@echo "Installing manpage to $(MANDIR)..."
	install -d $(MANDIR)
	install -m 644 $(MANPAGE) $(MANDIR)/$(MANPAGE)
	@echo "Creating manpage symlink $(MANDIR)/$(SYMLINK).1 -> $(MANPAGE)..."
	ln -sf $(MANPAGE) $(MANDIR)/$(SYMLINK).1
	@echo "Installation complete."
	@echo "  $(BINDIR)/$(SCRIPT)"
	@echo "  $(BINDIR)/$(SYMLINK) -> $(SCRIPT)"
	@echo "  $(MANDIR)/$(MANPAGE)"
	@echo "  $(MANDIR)/$(SYMLINK).1 -> $(MANPAGE)"

uninstall:
	@echo "Uninstalling $(SCRIPT) and $(SYMLINK) from $(BINDIR)..."
	rm -f $(BINDIR)/$(SCRIPT)
	rm -f $(BINDIR)/$(SYMLINK)
	@echo "Uninstalling manpages from $(MANDIR)..."
	rm -f $(MANDIR)/$(MANPAGE)
	rm -f $(MANDIR)/$(SYMLINK).1
	@echo "Uninstallation complete."

test:
	@echo "Running shellcheck on $(SCRIPT)..."
	shellcheck $(SCRIPT)
	@echo "Shellcheck passed."
