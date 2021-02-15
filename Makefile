GITHUB_URL := https://github.com/HeroTransitions/Hero/

include .makefiles/ludicrous.mk
include .makefiles/bundler.mk
include .makefiles/ios.mk

PLATFORM := 'iOS'
TEST_SCHEME := 'HeroExamples'
WORKSPACE := 'Hero.xcworkspace'

%:
	@:

args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`

#> Lint the podspec for upload
pod_lint:
	bundle exec pod spec lint Hero.podspec

#> Build API documentation; https://github.com/realm/jazzy
jazzy:
	@jazzy --config .jazzy.yaml

#> Markdown API using sourcedocs; https://github.com/eneko/SourceDocs
sourcedocs:
	@sourcedocs generate -clean --spm-module Hero --output-folder docs

#> Run tests
swift_test:
	swift test --parallel

#> Build debug
swift_debug:
	swift build --skip-update --jobs 4 --configuration debug

#> Build release
swift_release:
	swift build --skip-update --jobs 4 --configuration release
