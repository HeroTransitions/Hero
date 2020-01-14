# Provides a dependecy, `bundle`, which runs bundle install when necessary.
# Override bundle install options by setting BUNDLE_INSTALL_OPTS.
BE := bundle exec
BUNDLE_INSTALL_OPTS ?=

Gemfile.lock: Gemfile FORCE | _program_bundle
	@bundle check > /dev/null 2>&1 && \
		( $(call _log,rubygems up-to-date) ) || \
		( $(call _log,installing rubygems); \
		  bundle install $(BUNDLE_INSTALL_OPTS) )

#> installs rubygems
bundle:: Gemfile.lock

.PHONY: bundle
