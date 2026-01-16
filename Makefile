# Makefile for which

PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1
PROFILED = /etc/profile.d
SCRIPT = which
MANPAGE = which.1

.PHONY: all help install uninstall install-sourceable uninstall-sourceable test shellcheck functional benchmark

all: help

help:
	@echo "which Makefile targets:"
	@echo "  make install            - Install which and manpage to $(PREFIX)"
	@echo "  make uninstall          - Remove which and manpage"
	@echo "  make install-sourceable - Install to /etc/profile.d (12x faster)"
	@echo "  make uninstall-sourceable - Remove from /etc/profile.d"
	@echo "  make test               - Run shellcheck + functional tests"
	@echo "  make shellcheck         - Run shellcheck only"
	@echo "  make functional         - Run functional tests only"
	@echo "  make benchmark          - Run performance benchmarks"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX=$(PREFIX)  - Installation prefix (default: /usr/local)"

install:
	@echo "Installing $(SCRIPT) to $(BINDIR)..."
	install -d $(BINDIR)
	install -m 755 $(SCRIPT) $(BINDIR)/$(SCRIPT)
	@echo "Installing manpage to $(MANDIR)..."
	install -d $(MANDIR)
	install -m 644 $(MANPAGE) $(MANDIR)/$(MANPAGE)
	@echo "Installation complete."
	@echo "  $(BINDIR)/$(SCRIPT)"
	@echo "  $(MANDIR)/$(MANPAGE)"

uninstall:
	@echo "Uninstalling $(SCRIPT) from $(BINDIR)..."
	rm -f $(BINDIR)/$(SCRIPT)
	@echo "Uninstalling manpage from $(MANDIR)..."
	rm -f $(MANDIR)/$(MANPAGE)
	@echo "Uninstallation complete."

install-sourceable:
	@echo "Installing $(SCRIPT) to $(PROFILED)/which.sh..."
	install -d $(PROFILED)
	install -m 644 $(SCRIPT) $(PROFILED)/which.sh
	@echo "Installation complete: $(PROFILED)/which.sh"
	@echo "New shells will have which() function (12x faster)"

uninstall-sourceable:
	@echo "Removing which.sh from $(PROFILED)..."
	rm -f $(PROFILED)/which.sh
	@echo "Uninstallation complete."

test: shellcheck functional

shellcheck:
	@echo "Running shellcheck..."
	shellcheck $(SCRIPT) tests/*.sh
	@echo "Shellcheck passed."

functional:
	@echo "Running functional tests..."
	@chmod +x tests/test_which.sh
	@./tests/test_which.sh

benchmark:
	@echo "Running benchmarks..."
	@chmod +x tests/benchmark.sh
	@./tests/benchmark.sh
