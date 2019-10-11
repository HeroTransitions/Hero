# The "main" utility functions and helpers useful for the common case. Most
# ludicrous makefiles require this file, so it's sensible to `include` it first.
INCLUDES_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

LUDICROUS_BRANCH := master
LUDICROUS_DOWNLOAD_URL := https://raw.githubusercontent.com/martinwalsh/ludicrous-makefiles/$(LUDICROUS_BRANCH)/includes

# Generates help text from specialized comments (lines prefixed with a `#>`).
# Free-standing comments are included in the prologue of the help text, while
# those immediately preceding a recipe will be displayed along with their
# respective target names
#
# Targets: help
# Requires: awk
# Side effects:
#   * .DEFAULT_GOAL is set to to the `help` target from this file
#
HELP_PROGRAM := $(INCLUDES_DIR)/help.awk

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

#> displays this message
# help: _HELP_F := $(firstword $(MAKEFILE_LIST))
# help: | _program_awk
# 	@awk -f $(HELP_PROGRAM) $(wordlist 2,$(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) $(_HELP_F)  # always prefer help from the top-level makefile
TARGET_MAX_CHAR_NUM=20
#> Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\0-9]+:/ { \
		helpMessage = match(lastLine, /^#> (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' \
	$(MAKEFILE_LIST)

.PHONY: help
.DEFAULT_GOAL := help

# Helper target for declaring an external executable as a recipe dependency.
# For example,
#   `my_target: | _program_awk`
# will fail before running the target named `my_target` if the command `awk` is
# not found on the system path.
_program_%: FORCE
	@_=$(or $(shell which $* 2> /dev/null),$(error `$*` command not found. Please install `$*` and try again))

# Helper target for declaring required environment variables.
#
# For example,
#   `my_target`: | _var_PARAMETER`
#
# will fail before running `my_target` if the variable `PARAMETER` is not declared.
_var_%: FORCE
	@_=$(or $($*),$(error `$*` is a required parameter))

# The defult build dir, if we have only one it'll be easier to cleanup
BUILD_DIR =: build

$(BUILD_DIR):
	mkdir -p $@

# text manipulation helpers
_awk_case = $(shell echo | awk '{ print $(1)("$(2)") }')
lc = $(call _awk_case,tolower,$(1))
uc = $(call _awk_case,toupper,$(1))

# Useful for forcing targets to build when .PHONY doesn't help
FORCE:
.PHONY: FORCE

# Provides two callables, `log` and `_log`, to facilitate consistent
# user-defined output, formatted using tput when available.
#
# Override TPUT_PREFIX to alter the formatting.
TPUT        := $(shell which tput 2> /dev/null)
TPUT_PREFIX := $(TPUT) bold
TPUT_SUFFIX := $(TPUT) sgr0
TPUT_RED    := $(TPUT) setaf 1
TPUT_GREEN  := $(TPUT) setaf 2
TPUT_YELLOW := $(TPUT) setaf 3
LOG_PREFIX  ?= ===>

ifeq (,$(and $(TPUT),$(TERM)))

define _log
echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"
endef

define _warn
echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"
endef

define _error
echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"
endef

else

define _log
$(TPUT_PREFIX); echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"; $(TPUT_SUFFIX)
endef

define _warn
$(TPUT_PREFIX); $(TPUT_YELLOW); echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"; $(TPUT_SUFFIX)
endef

define _error
$(TPUT_PREFIX); $(TPUT_RED); echo "$(if $(LOG_PREFIX),$(LOG_PREFIX) )$(1)"; $(TPUT_SUFFIX)
endef

endif

define log
	@$(_log)
endef

# Removes build artifacts, implement with your own `clean::` target to remove additional artifacts.
# See https://www.gnu.org/software/make/manual/make.html#Double_002dColon for more information.
#> removes build artifacts
clean::
	@:
.PHONY: clean

# Provides callables `download` and `download_to`.
# * `download`: fetches a url `$(1)` piping it to a command specified in `$(2)`.
#   Usage: `$(call download,$(URL),tar -xf - -C /tmp/dest)`
#
# * `download_to`: fetches a url `$(1)` and writes it to a local path specified in `$(2)`.
#   Usage: `$(call download_to,$(URL),/tmp/dest)`
#
# Requires: curl
#
# Additional command line parameters may be passed to curl via CURL_OPTS.
# For example, `CURL_OPTS += -s`.
#
CURL_OPTS ?= --location --silent

ifneq ($(shell which curl 2> /dev/null),)
DOWNLOADER = curl $(CURL_OPTS)
DOWNLOAD_FLAGS :=
DOWNLOAD_TO_FLAGS := --write-out "%{http_code}" -o
else
NO_DOWNLOADER_FOUND := Unable to locate a suitable download utility (curl)
endif

define download
	$(if $(NO_DOWNLOADER_FOUND),$(error $(NO_DOWNLOADER_FOUND)),$(DOWNLOADER) $(DOWNLOAD_FLAGS) "$(1)" | $(2))
endef

define download_to
	$(if $(NO_DOWNLOADER_FOUND),$(error $(NO_DOWNLOADER_FOUND)),$(DOWNLOADER) $(DOWNLOAD_TO_FLAGS) $(2) "$(1)")
endef

# Provides variables useful for determining the operating system we're running
# on.
#
# OS_NAME will reflect the name of the operating system: Darwin, Linux or Windows
# OS_CPU will be either x86 (32bit) or amd64 (64bit)
# OS_ARCH will be either i686 (32bit) or x86_64 (64bit)
#
ifeq (Windows_NT,$(OS))
OS_NAME := Windows
OS_CPU  := $(call _lower,$(PROCESSOR_ARCHITECTURE))
OS_ARCH := $(if $(findstring amd64,$(OS_CPU)),x86_64,i686)
else
OS_NAME := $(shell uname -s)
OS_ARCH := $(shell uname -m)
OS_CPU  := $(if $(findstring 64,$(OS_ARCH)),amd64,x86)
endif

# Install ludicrous plugins by include directive
PLUGIN_TARGETS := $(abspath $(INCLUDES_DIR)/%.mk) $(subst $(CURDIR)/,,$(abspath $(INCLUDES_DIR)/%.mk))

ifneq (B,$(findstring B,$(MAKEFLAGS)))
$(PLUGIN_TARGETS):
	@[ ! -f $@ ] && \
	( \
		$(call _log,downloading ludicrous plugin to $@); \
		STATUS="$$($(call download_to,$(LUDICROUS_DOWNLOAD_URL)/$(notdir $@),$@))"; \
			 if [ $$STATUS -ne 200 ]; then $(call _error,ludicrous plugin $(notdir $@) not found.); exit 1; fi \
	)
else
$(PLUGIN_TARGETS):
	@:
endif
