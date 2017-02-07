<img src="https://cdn.rawgit.com/lkzhao/Hero/bff6d87907006d1847ed0b7121e9fb4ac4d68320/Resources/Hero.svg" width="388"/>

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Hero.svg?style=flat)](http://cocoapods.org/pods/Hero)
[![License](https://img.shields.io/cocoapods/l/Hero.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/LICENSE?raw=true)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

[中文 README](https://github.com/lkzhao/Hero/blob/master/README.zh-cn.md)

## Introduction

**Hero** is a library for building iOS view controller transitions. It provides a layer on top of the UIKit's cumbersome transition APIs. Making custom transitions an easy task for developers.

### Features
<img src="https://cdn.rawgit.com/lkzhao/Hero/f6e87630249bf398cbc138c16eb9e4e3a301cace/Resources/basic.svg"/>
<img src="https://cdn.rawgit.com/lkzhao/Hero/f6e87630249bf398cbc138c16eb9e4e3a301cace/Resources/effects.svg"/>

#### With Hero, you can easily mix & match these effects to build your own custom transition.

At its core, Hero is similar to Keynote's **Magic Move**. It checks the `heroID` property on all source and destinations views. Every matched view pairs are then automatically transitioned from its old state to its new state.

Hero can also construct animations for unmatched views. It is easy to define these animations via the `heroModifiers` property. Hero will run these animations alongside the **Magic Move** animations. All of these can be interactive, too.

By default, Hero provides **dynamic duration & easing** based on the [Material Design Motion Guide](https://material.io/guidelines/motion/duration-easing.html). The duration is determined by the distance and size change. The easing curve is selected base on whether or not the view is entering or exiting the screen. It save you the hassle while providing consistent and delightful animations.

Hero does not make any assumption about how the view is built or structured. It will not modify any of your views' states other than hiding them during the animation. This means that it works with **Auto Layout**, **programmatic layout**, **UICollectionView** (without modifying its layout object), **UITableView**, **UINavigationController**, **UITabBarController**, etc... 

## Example Gallery

Checkout the [example gallery blog post](http://lkzhao.com/2016/12/28/hero.html) for a general idea of what you can achieve with **Hero**

## Usage Example 1

<img src="https://cdn.rawgit.com/lkzhao/Hero/e4b0d15a15d738ac4b163797816059c199100e22/Resources/simple-v1.svg" />
<img src="https://cdn.rawgit.com/lkzhao/Hero/e4b0d15a15d738ac4b163797816059c199100e22/Resources/simple-v2.svg" />
<img src="https://cdn.rawgit.com/lkzhao/Hero/e4b0d15a15d738ac4b163797816059c199100e22/Resources/simple-animation.svg" />

##### View Controller 1
```swift
redView.heroID = "foo"
greyView.heroID = "bar"
```

##### View Controller 2
```swift
isHeroEnabled = true
redView.heroID = "foo"
greyView.heroID = "bar"
greenView.heroModifiers = [.translate(x:0, y:100), .scale(0.5)]
```


## Usage Example 2
<img src="https://cdn.rawgit.com/lkzhao/Hero/ecec15de7747d9541db9af62e4001da6bf0b3896/Resources/advance-v1.svg" />
<img src="https://cdn.rawgit.com/lkzhao/Hero/e4b0d15a15d738ac4b163797816059c199100e22/Resources/advance-v2.svg" />
<img src="https://cdn.rawgit.com/lkzhao/Hero/e4b0d15a15d738ac4b163797816059c199100e22/Resources/advance-animation.svg" />

##### View Controller 1
```swift
greyView.heroID = "foo"
```

##### View Controller 2
```swift
isHeroEnabled = true
greyView.heroID = "foo"

// collectionView is the parent view of all red cells
collectionView.heroModifiers = [.cascade]
for cell in redCells {
	cell.heroModifiers = [.fade, .scale(0.5)]
}
```

You can do these in the **storyboard** too!

<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardView.png" width="267px"/> 
<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardViewController.png" width="267px"/>

## Usage Guide

* [Installation](https://github.com/lkzhao/Hero/wiki/Usage-Guide#installation)
* [Usage](https://github.com/lkzhao/Hero/wiki/Usage-Guide#usage)
	* [Storyboard](https://github.com/lkzhao/Hero/wiki/Usage-Guide#storyboard)
	* [In Code](https://github.com/lkzhao/Hero/wiki/Usage-Guide#in-code)
* [Attributes](https://github.com/lkzhao/Hero/wiki/Usage-Guide#attributes)
	* [HeroID](https://github.com/lkzhao/Hero/wiki/Usage-Guide#heroid)
	* [HeroModifiers](https://github.com/lkzhao/Hero/wiki/Usage-Guide#heromodifiers)
	* [HeroModifierString](https://github.com/lkzhao/Hero/wiki/Usage-Guide#heromodifierstring)
* [Modifiers](https://github.com/lkzhao/Hero/wiki/Usage-Guide#modifiers)
	* [Basic Modifiers](https://github.com/lkzhao/Hero/wiki/Usage-Guide#basic-modifiers)
	* [Advance Modifiers](https://github.com/lkzhao/Hero/wiki/Usage-Guide#advance-modifiers)
	* [Arc](https://github.com/lkzhao/Hero/wiki/Usage-Guide#arc-modifier)
	* [Source](https://github.com/lkzhao/Hero/wiki/Usage-Guide#source-modifier)
	* [Cascade](https://github.com/lkzhao/Hero/wiki/Usage-Guide#cascade-modifier)
	* [IgnoreSubviewModifiers](https://github.com/lkzhao/Hero/wiki/Usage-Guide#ignoresubviewmodifiers-modifier)
	* [UseScaleBasedSizeChange](https://github.com/lkzhao/Hero/wiki/Usage-Guide#usescalebasedsizechange-modifier)
* [Coordinate Space](https://github.com/lkzhao/Hero/wiki/Usage-Guide#coordinate-space)
	* [Global](https://github.com/lkzhao/Hero/wiki/Usage-Guide#global-coordinate-space-default-before-013)
	* [Local](https://github.com/lkzhao/Hero/wiki/Usage-Guide#local-coordinate-space-default-after-013)
* [Snapshot Types](https://github.com/lkzhao/Hero/wiki/Usage-Guide#snapshot-types)
* [Navigation Helpers (dismiss, replace, unwind)](https://github.com/lkzhao/Hero/wiki/Usage-Guide#navigation-helpers-dismiss-replace-unwind)
* [UINavigationController & UITabBarController](https://github.com/lkzhao/Hero/wiki/Usage-Guide#uinavigationcontroller--uitabbarcontroller)

##### NOTE: Hero won't work on iPhone 7 Simulators due to a [bug](https://forums.developer.apple.com/thread/63438) by Apple. Try using other simulators or a real device when working with Hero.

## Interactive Transition Tutorials

[Interactive transitions with Hero (Part 1)](http://lkzhao.com/2017/02/05/hero-interactive-transition.html)

## Contribute

We welcome any contributions. Please read the [Contribution Guide](https://github.com/lkzhao/Hero/wiki/Contribution-Guide).

## License

Hero is available under the MIT license. See the LICENSE file for more info.
