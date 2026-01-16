# Makefile for whichx

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1
SCRIPT = whichx
SYMLINK = which
MANPAGE = whichx.1

.PHONY: all help install uninstall test shellcheck functional benchmark

all: help

help:
	@echo "whichx Makefile targets:"
	@echo "  make install    - Install whichx, manpage, and create which symlink"
	@echo "  make uninstall  - Remove whichx, manpage, and which symlink"
	@echo "  make test       - Run shellcheck + functional tests"
	@echo "  make shellcheck - Run shellcheck only"
	@echo "  make functional - Run functional tests only"
	@echo "  make benchmark  - Run performance benchmarks vs old.which"
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

test: shellcheck functional

shellcheck:
	@echo "Running shellcheck..."
	shellcheck $(SCRIPT) tests/*.sh
	@echo "Shellcheck passed."

functional:
	@echo "Running functional tests..."
	@chmod +x tests/test_whichx.sh
	@./tests/test_whichx.sh

benchmark:
	@echo "Running benchmarks..."
	@chmod +x tests/benchmark.sh
	@./tests/benchmark.sh
