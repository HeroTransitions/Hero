SHELL := /bin/bash
.PHONY: help update pull bootstrap

RUBY := $(shell command -v ruby 2>/dev/null)
CARTHAGE := $(shell command -v carthage 2>/dev/null)
PODS := $(shell command -v pod 2>/dev/null)
HOMEBREW := $(shell command -v brew 2>/dev/null)
ROME := $(shell command -v rome 2>/dev/null)
BUNDLER := $(shell command -v bundle 2>/dev/null)
CARTING := $(shell command -v carting 2>/dev/null)
SWIFTGEN := $(shell command -v swiftgen 2>/dev/null)
SWIFTLINT := $(shell command -v swiftlint 2>/dev/null)
PLATFORM := 'iOS,tvOS,macOS,watchOS'

WORKSPACE := '$(shell ls -d *.xc* | head -1)'

default: help

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

#>----- Helper functions ------

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

_tag: | _var_VERSION
	make --no-print-directory -B README.md
	git commit -am "Tagging release $(VERSION)"
	git tag -a $(VERSION) $(if $(NOTES),-m '$(NOTES)',-m $(VERSION))
.PHONY: _tag

_push: | _var_VERSION
	git push origin $(VERSION)
	git push origin master
.PHONY: _push

#> Install dependencies.
setup: \
	pre_setup \
	check_for_ruby \
	check_for_homebrew \
	update_homebrew \
	install_carthage \
	install_bundler_gem \
	install_ruby_gems \
	install_carthage_dependencies

#> Install extra tools (carting, swiftlint, swift-gen...)
install_extras:
	pre_setup \
	check_for_ruby \
	check_for_homebrew \
	update_homebrew \
	install_carthage \
	install_swift_lint \
	install_carting \
	install_rome \
	install_swiftgen

pull_request: \
	test \
	codecov_upload \
	danger

pre_setup:
	$(info iOS project setup ...)

check_for_ruby:
	$(info Checking for Ruby ...)

ifeq ($(RUBY),)
	$(error Ruby is not installed)
endif

check_for_homebrew:
	$(info Checking for Homebrew ...)

ifeq ($(HOMEBREW),)
	$(error Homebrew is not installed)
endif

update_homebrew:
	$(info Update Homebrew ...)

	brew update

install_swift_lint:
	$(info Install swiftlint ...)

ifneq ($(SWIFTLINT),)
	brew install swiftlint
else
	$(info Already have, skipping.)
endif

install_bundler_gem:
	$(info Checking and install bundler ...)

ifeq ($(BUNDLER),)
	gem install bundler -v '~> 1.17'
else
	gem update bundler '~> 1.17'
endif

install_ruby_gems:
	$(info Install Ruby Gems ...)

	bundle check || bundle install

install_carthage:
	$(info Install Carthage ...)

ifneq ($(CARTHAGE),)
	brew install carthage
else
	$(info Already have, skipping.)
endif

install_carting:
	$(info Install Carting ...)

ifneq ($(CARTING),)
	brew install artemnovichkov/projects/carting
else
	$(info Already have, skipping.)
endif

install_swiftgen:
	$(info Install Swift-Gen (https://github.com/SwiftGen/SwiftGen) ...)

ifneq ($(SWIFTGEN),)
	brew install swiftgen
else
	$(info Already have, skipping.)
endif

gitpull:
	$(info Pulling new commits ...)

	git pull

#> -- QA Task Runners --

codecov_upload:
	curl -s https://codecov.io/bash | bash

#> Danger a GitHub PR Locally. Useage `make danger_pr PR={PR#} autocorrect
danger_pr:
	bundle exec danger pr "$(GITHUB_URL:/=)/pull/$(PULL)"

danger:
	bundle exec danger

#> SwiftLint autocorrect
autocorrect:
	bundle exec swiftlint autocorrect --config .swiftlint.yml

## -- Testing --

#> Run test on all targets
test:
	xcodebuild test -scheme $(TEST_SCHEME) -workspace  $(WORKSPACE) -destination 'platform=iOS Simulator,OS=14.4,name=iPhone 12' -parallelizeTargets -showBuildTimingSummary -enableThreadSanitizer YES CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=YES | tee xcodebuild.log | xcpretty

#> -- Building --

#> Make a .zip package of frameworks
package:
	carthage build --no-skip-current --platform $(PLATFORM)
	carthage archive $(MODULE_NAME)

#> tag and release to github
release: | _var_VERSION
	@if ! git diff --quiet HEAD; then \
		( $(call _error,refusing to release with uncommitted changes) ; exit 1 ); \
	fi
	test
	package
	make --no-print-directory _tag VERSION=$(VERSION)
	make --no-print-directory _push VERSION=$(VERSION)

#> Open the workspace
open:
	open $(WORKSPACE)

#> Setup the project, git-hooks etc
init:
	git config core.hooksPath .githooks

