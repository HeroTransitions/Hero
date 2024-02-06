# CHANGELOG

The changelog for `Hero`. Also see the [releases](https://github.com/HeroTransitions/Hero/releases) on GitHub.

--------------------------------------

## [1.6.3](https://github.com/HeroTransitions/Hero/releases/tag/1.6.3)

- 1ac98e7 Adaption for visionOS.
- 5e05761 Merge pull request #771 from HeroTransitions/feature/CICDFix
- c9a98cf CI/CI build and test, matrix platforms fix?
- 2f8096d build.yml test.yml update github runner env
- 45aed92 Readme add api docs link
- a7d2682 README.md update ios/xcode version badges
- 211df4b README.md Add unit test and swift pm action badges
- bff4221 swiftlint fix
- a47dce4 Merge pull request #749 from tadija/feature/xcode14-warnings
- fd2ba86 Fix lint warnings
- 5c053a6 Fix build warnings with Xcode 14.0

## [1.6.2](https://github.com/HeroTransitions/Hero/releases/tag/1.6.2)

### Fixed

- [#717](https://github.com/HeroTransitions/Hero/issues/717)
- [#734](https://github.com/HeroTransitions/Hero/issues/734)
- [#735](https://github.com/HeroTransitions/Hero/issues/735)
- [#736](https://github.com/HeroTransitions/Hero/issues/736)
- [#739](https://github.com/HeroTransitions/Hero/issues/739)
- [#740](https://github.com/HeroTransitions/Hero/issues/740) Fix build warings in XCode 13.4.1 c30a7a867d3bc420e90ad276d9bf12287628ce87
- [#742](https://github.com/HeroTransitions/Hero/issues/742) Add `anchorPoint` support for transitioning a76e9f6dbeefb530743994634d37235e59401911


## [1.6.1](https://github.com/HeroTransitions/Hero/releases/tag/1.6.1)

### Added

- git ignore .zip files

### Changed

- closes #703 Move CI depends to Mint
### Fixed

- Update README.md remove dead link closes #708
- Update the link to material design's motion duration easing links.
- fixes #704 SPM missing imports

## [1.6.0](https://github.com/HeroTransitions/Hero/releases/tag/1.6.0)
### Added

- #695 - Swift 5 support
- #628 - Swift Package Manager Support
- #623 - Swift UI support and example
- #681 - Application extension target support
- #595 - Add Accio supported badge
- #619 - XCode 11/12 support in example
- CI/CD improvements
### Changed

- #648 - Updated iOS version support
- #576 - Usage guide updates

### Fixed

- #698 - Warnings fix
- #585 - replaceViewControllers now calls the completion
- #559 - Resuming property animator from current fraction
- #465 - fix keyboard transition

## [1.5.0](https://github.com/HeroTransitions/Hero/releases/tag/1.5.0)
### Added

- Use custom snapshot for views that implement `HeroCustomSnapshotView`.
[#541](https://github.com/HeroTransitions/Hero/pull/541) by [@ManueGE](https://github.com/ManueGE)

### Changed

- Added support for right to left languages.
[#520](https://github.com/HeroTransitions/Hero/pull/520) by [@ManueGE](https://github.com/ManueGE)

- The hidden state of subviews are now taken into account in optimized snapshot type for `UIImageView`.
[#521](https://github.com/HeroTransitions/Hero/pull/521) by [@ManueGE](https://github.com/ManueGE)

## [1.4.0](https://github.com/HeroTransitions/Hero/releases/tag/1.4.0)

### Added

- Added support for Swift 4.2.
[#534](https://github.com/HeroTransitions/Hero/pull/534) by [@rennarda](https://github.com/rennarda)

## [1.3.1](https://github.com/HeroTransitions/Hero/releases/tag/1.3.1)

### Fixed

- Fixed the retain cycle caused by strong references to `previousNavigationDelegate` and `previousTabBarDelegate`.
[#516](https://github.com/HeroTransitions/Hero/pull/516) by [@mkieselmann](https://github.com/mkieselmann)

## [1.3.0](https://github.com/HeroTransitions/Hero/releases/tag/1.3.0)

### Added
- Adds an optional completion block parameter to the `dismissViewController` and `replaceViewController` methods.
[#456](https://github.com/HeroTransitions/Hero/pull/456) by [@kartikthapar](https://github.com/kartikthapar)

### Changed
- Allows previous `UINavigationController` delegate to handle delegate events.
[#430](https://github.com/HeroTransitions/Hero/pull/430) by [@bradphilips](https://github.com/bradphilips)

### Fixed
- Fixed shadows being cutoff by snapshots.
[#440](https://github.com/HeroTransitions/Hero/pull/440) by [@2blane](https://github.com/2blane)
- Fixed animation flickering on CALayer animation.
[f4dab9](https://github.com/HeroTransitions/Hero/commit/f4dab9ed2ab88ae065605199d5aca7706b07c2ad) by [@lkzhao](https://github.com/lkzhao)
