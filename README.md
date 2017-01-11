<img src="https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@2x.png?raw=true" width="388"/>

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
<img src="https://cdn.rawgit.com/lkzhao/Hero/e6c77629fcf2ea1c9b8526f74d250a2fea68ae5c/Resources/basic.svg"/>
<img src="https://cdn.rawgit.com/lkzhao/Hero/b8f01051e9e8ce0cdc8eb7888c6d7ffa2344d96a/Resources/effects.svg"/>

#### With Hero, you can easily mix & match these effects to build your own custom transition.

At its core, Hero is similar to Keynote's **Magic Move**. It checks the `heroID` property on all source and destinations views. Every matched view pairs are then automatically transitioned from it's old state to it's new state.

Hero can also construct animations for unmatched views. It is easy to define these animations via the `heroModifiers` property. Hero will run these animations alongside the **Magic Move** animations. All of these can be interactive, too.

By default, Hero provides **dynamic duration & easing** based on the [Material Design Motion Guide](https://material.io/guidelines/motion/duration-easing.html). The duration is determined by the distance and size change. The easing curve is selected base on whether or not the view is entering or exiting the screen. It save you the hassle while providing consistent and delightful animations.

Hero does not make any assumption about how the view is built or structured. It will not modify any of your views' states other than hiding them during the animation. This means that it works with **autolayout**, **programmatic layout**, **UICollectionView**(without modifying its layout object), **UITableView**, **UINavigationController**, **UITabBarController**, etc... 

## Video Demos
The following videos give you a general idea of what you can do with **Hero**

1. Video overview of the **example project**.
2. Video overview of the **built-in debugger** that display timeline, arc curve, and 3d informations.
3. Video overview of the usage with [Injection App](http://johnholdsworth.com/injection.html) to provide **dynamic modifications** in realtime. Changing `HeroID` or `HeroModifiers` **without** recompiling!

<a href="https://youtu.be/-6L79or6Iq8"><img src="https://github.com/lkzhao/Hero/blob/master/Resources/overview.png?raw=true" height="300"/></a>
<a href="https://youtu.be/NFhA6qZdunA"><img src="https://github.com/lkzhao/Hero/blob/master/Resources/debugger.png?raw=true" height="300"/></a>
<a href="https://youtu.be/m8eeO_GETeA"><img src="https://github.com/lkzhao/Hero/blob/master/Resources/liveInjection.png?raw=true" height="300"/></a>

## Installation & Usage Guide
Hero is available on Carthage & Cocoapods. See the **[usage guide](https://github.com/lkzhao/Hero/wiki/Usage-Guide)** for instructions.

##### NOTE: Hero won't work on iPhone 7 Simulators due to a [bug](https://forums.developer.apple.com/thread/63438) by Apple. Try using other simulators or a real device when working with Hero.

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
<img src="https://cdn.rawgit.com/lkzhao/Hero/e4b0d15a15d738ac4b163797816059c199100e22/Resources/advance-v1.svg" />
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

## Contribute

We welcome any contributions. Please read the [Contribution Guide](https://github.com/lkzhao/Hero/wiki/Contribution-Guide).

## License

Hero is available under the MIT license. See the LICENSE file for more info.
