# frozen_string_literal: true

source 'https://rubygems.org'
#ruby '~> 2.5.1'

gem 'cocoapods', '~> 1.10'
gem 'cocoapods-check'
gem 'cocoapods-generate'
gem 'cocoapods-githooks'      # Sync .git-hooks across team members at `pod install` time
gem 'cocoapods-packager'      # Generate a framework or static library from a podspec. https://github.com/CocoaPods/cocoapods-packager
gem 'cocoapods-repo-update'   # Fixes issues with CI not updating specs

# Temporary workaround for bug in binary file diffing
# https://github.com/danger/danger/issues/1055
# https://github.com/ruby-git/ruby-git/pull/405
gem 'git', git: 'https://github.com/jcouball/ruby-git.git'

gem 'fastlane'
gem 'xcode-install'

group :documentation do
# gem 'jazzy', '~> 0.11'
end

group :test do
  gem 'git_diff_parser'
  gem 'xcpretty'

  gem 'danger'
  gem 'danger-auto_label'
  gem 'danger-swiftlint'

  # Danger plugin to validate the code coverage of the files changed
  #     - Gem:     danger-xcov
  #     - URL:     https://github.com/nakiostudio/danger-xcov
  gem 'danger-xcov'
end

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
