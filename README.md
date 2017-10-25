<img src="https://cdn.rawgit.com/lkzhao/Hero/427d5f2/Resources/Hero.svg" width="388"/>

**Hero** is a library for building iOS view controller transitions. It provides a declarative layer on top of the UIKit's cumbersome transition APIs—making custom transitions an easy task for developers.

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Hero.svg?style=flat)](http://cocoapods.org/pods/Hero)
[![License](https://img.shields.io/cocoapods/l/Hero.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/LICENSE?raw=true)
![Xcode 9.0+](https://img.shields.io/badge/Xcode-9.0%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 4.0+](https://img.shields.io/badge/Swift-4.0%2B-orange.svg)
[![中文 README](https://img.shields.io/badge/%E4%B8%AD%E6%96%87-README-blue.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/README.zh-cn.md)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NT5F7Y2MPV7RE)

<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/features.svg"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/features2.svg"/>

Hero is similar to Keynote's **Magic Move**. It checks the `heroID` property on all source and destination views. Every matched view pair is then automatically transitioned from its old state to its new state.

Hero can also construct animations for unmatched views. It is easy to define these animations via the `heroModifiers` property. Hero will run these animations alongside the **Magic Move** animations. All of these animations can be **interactively controlled** by user gestures.

At view controller level, Hero provides several template transitions that you can set through `heroModalAnimationType`, `heroNavigationAnimationType`, and `heroTabBarAnimationType`. These can be used as the foundation of your custom transitions. Combine with `heroID` & `heroModifiers` to make your own unique transitions.

<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/defaultAnimations.svg"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/defaultAnimations2.svg"/>

By default, Hero provides **dynamic duration** based on the [Material Design Motion Guide](https://material.io/guidelines/motion/duration-easing.html). Duration is automatically determined by changes to distance and size—saving you the hassle, while providing consistent and delightful animations.

Hero doesn't make any assumptions about how the view is built or structured. It won't modify any of your views' states other than hiding them during the animation. This makes it work with **Auto Layout**, **programmatic layout**, **UICollectionView** (without modifying its layout object), **UITableView**, **UINavigationController**, **UITabBarController**, etc... 


## Example Gallery

Checkout the [Example Gallery Blog Post](http://lkzhao.com/2016/12/28/hero.html) for a general idea of what you can achieve with **Hero**

## Usage Example 1

<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/simple.svg" />

##### View Controller 1
```swift
redView.heroID = "ironMan"
blackView.heroID = "batMan"
```

##### View Controller 2
```swift
isHeroEnabled = true
redView.heroID = "ironMan"
blackView.heroID = "batMan"
whiteView.heroModifiers = [.translate(y:100)]
```


## Usage Example 2
<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/advanced.svg" />

##### View Controller 1
```swift
greyView.heroID = "skyWalker"
```

##### View Controller 2
```swift
isHeroEnabled = true
greyView.heroID = "skyWalker"

// collectionView is the parent view of all red cells
collectionView.heroModifiers = [.cascade]
for cell in redCells {
	cell.heroModifiers = [.fade, .scale(0.5)]
}
```

You can do these in the **storyboard** too!

<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardView.png" width="267px"/> 
<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardViewController.png" width="267px"/>

## Documentations

Checkout the **[WIKI PAGES (Usage Guide)](https://github.com/lkzhao/Hero/wiki/Usage-Guide)** for documentations. 

For more up-to-date ones, please see the header-doc. (use **alt+click** in Xcode)
<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/headerDoc.png" width="521px"/>

## Interactive Transition Tutorials

[Interactive transitions with Hero (Part 1)](http://lkzhao.com/2017/02/05/hero-interactive-transition.html)

## FAQ

#### White flashes occurs on iPhone 7 (Plus) Simulators

Hero **does not work** on iPhone 7 (Plus) Simulators due to an [Apple bug](https://forums.developer.apple.com/thread/63438). Please use other simulators or a real device when working with Hero.

#### Not able to use Hero transition even when `isHeroEnabled` is set to true

Make sure that you have also enabled `isHeroEnabled` on the navigation controller if you are doing a push/pop inside the navigation controller.

#### Views being covered by another matched view during the transition

Matched views use global coordinate space while unmatched views use local coordinate space by default. Local coordinate spaced views might be covered by other global coordinate spaced views. To solve this, use the `useGlobalCoordinateSpace` modifier on the views being covered. Checkout [Coordinate Space Wiki page](https://github.com/lkzhao/Hero/wiki/Coordinate-Space) for details.

#### Weird behavior with UIVisualEffectView

UIVisualEffectView is quite hard to animate due to its private implementation and incompatibility with  `snapshotAfterScreenUpdate` and some Core Animation APIs. We are trying to get these solved as much as we can. Currently, as of 0.3.2, only unmatched UIVisualEffectView with noninteractive `.fade` animation is supported.

#### Push animation is shown along side my custom animation

This is the default animation for navigation controller provided by Hero. To disable the push animation, set `heroNavigationAnimationType` to `.fade` or `.none` on the navigation controller.

#### How do I use a different default animation when dismissing

You can use the animation type `.selectBy(presenting:dismissing)` to specify a different default animation for dismiss.

For example:

```swift
    heroModalAnimationType = .selectBy(presenting:.zoom, dismissing:.zoomOut)
```

## Contribute

We welcome any contributions. Please read the [Contribution Guide](https://github.com/lkzhao/Hero/wiki/Contribution-Guide).
