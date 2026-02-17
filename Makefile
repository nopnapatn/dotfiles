# Dotfiles setup — run install script via make
# Usage: make          # same as make install
#        make install

SHELL := /bin/bash
DOTFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INSTALL_SCRIPT := $(DOTFILES_DIR)install.sh

.PHONY: install update help

install:
	@bash "$(INSTALL_SCRIPT)"

update:
	@git pull --ff-only
	@$(MAKE) install

# Default target
.DEFAULT_GOAL := install

help:
	@echo "Dotfiles Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make install   Run the dotfiles install script (default)"
	@echo "  make update    Pull latest changes and run install"
	@echo "  make help      Show this help"
