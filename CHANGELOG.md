# CHANGELOG

The changelog for `Hero`. Also see the [releases](https://github.com/HeroTransitions/Hero/releases) on GitHub.

--------------------------------------

## Upcoming release

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
