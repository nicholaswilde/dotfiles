SHELL := bash

.PHONY: all
all: bin lib dotfiles ## Installs the bin and etc directory files and the dotfiles.

.PHONY: dotfiles
dotfiles: ## Installs the dotfiles.
	@printf "\ninstalling dotfiles ...\n\n"
	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name "test.sh" -not -name ".bashrc.*" -not -name ".yamllint" -not -name ".pre-commit-config*"); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/$$f; \
	done; \
	gpg --list-keys || true; \
	mkdir -p $(HOME)/.gnupg;
	for file in $(shell find $(CURDIR)/.gnupg); do \
		f=$$(basename $$file); \
		ln -sfn $$file $(HOME)/.gnupg/$$f; \
	done; \
	mkdir -p $(HOME)/.config/gh;
	ln -snf $(CURDIR)/.config/gh/config.yml $(HOME)/.config/gh/config.yml;
	source ~/.bashrc

.PHONY: bin
bin: ## Installs the bin directory files.
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/bin -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
		sudo mkdir -p /usr/local/$$(dirname $$f); \
		sudo ln -sf $$file /usr/local$$f; \
	done

.PHONY: lib
lib: ## Installs the bin directory files.
	# add aliases for things in bin
	for file in $(shell find $(CURDIR)/lib -type f -not -name ".*.swp"); do \
		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
		sudo mkdir -p /usr/local/$$(dirname $$f); \
		sudo ln -sf $$file /usr/local$$f; \
	done

.PHONY: test
test: shellcheck yamllint ## Runs all the tests on the files in the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name df-shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		--platform linux/amd64 \
		jess/shellcheck ./test.sh

.PHONY: yamllint
yamllint:
	yamllint .

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
