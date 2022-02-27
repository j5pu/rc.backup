.PHONY: brew clean release tests

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(patsubst %/,%,$(dir $(MAKEFILE_PATH)))
BASH_ENV := $(ROOT_DIR)/.envrc
export BASH_ENV
SHELL := $(shell bash -c 'command -v bash') -e

brew:
	@brew bundle --quiet --cleanup --no-lock

release: src src/install
	@makeself release

tests:
	@bats.bash --run
