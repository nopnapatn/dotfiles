# Dotfiles setup — run install script via make
# Usage: make          # same as make install
#        make install

SHELL := /bin/bash
DOTFILES_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INSTALL_SCRIPT := $(DOTFILES_DIR)install.sh

.PHONY: install help

install:
	@bash "$(INSTALL_SCRIPT)"

# Default target
.DEFAULT_GOAL := install

help:
	@echo "Dotfiles Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make install   Run the dotfiles install script (default)"
	@echo "  make help      Show this help"
