<img src="https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@2x.png?raw=true" width="388"/>

Supercharged transition engine for iOS. Build your custom view transitions with few lines of code or even no code at all. Inspired by Polymer's [neon-animated-pages](https://elements.polymer-project.org/elements/neon-animation) and Keynote's `Magic Move`.

[![Version](https://img.shields.io/cocoapods/v/Hero.svg?style=flat)](http://cocoapods.org/pods/Hero)
[![License](https://img.shields.io/cocoapods/l/Hero.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/LICENSE?raw=true)
![Xcode 8.0+](https://img.shields.io/badge/Xcode-8.0%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

#####NOTE: Hero won't work on iPhone 7 Simulators due to a [bug](https://forums.developer.apple.com/thread/63438) by Apple. Try using other simulators or a real device when working with Hero.


## Video Demo
**[View here](https://youtu.be/-6L79or6Iq8)**

## Usage Guide
**[Read here](https://github.com/lkzhao/Hero/wiki/Usage-Guide)**

## Introduction

**Hero** is a library for building iOS view controller transitions. It provides an layer on top of the UIKit's cumbersome transition APIs. Making custom transitions a easy task for developers.

### Features
<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/basic.svg"/>

#### With Hero, you can easily mix & match these effects to build your own custom transition.

At its core, Hero provides a automatic transition similar to Keynote's `Magic Move`. It checks the `heroID` property on all source and destinations views. Every matched view pairs are then automatically transitioned from it's old state to it's new state.

Hero is also able to construct animations for unmatched views. It is easy to define these animations via the `heroModifiers` property. Hero will run these animations alongside the `Magic Move` animations. All of these can by interactive, too.

Hero does all of these without any assumption about how the view is built or structured. It will not modify any of your views' states other than hidding them during the animation. This means that it works great with autolayout, programmatic layout, UICollectionView, UITableView, UINavigationController etc... 

## A Simple Tutorial

<img src="https://github.com/lkzhao/Hero/blob/master/Resources/basic.gif?raw=true" width="362"/>

#### To achieve the transition above (3 steps)
1. **Setup the view controllers and construct the view hierarchy**

  <img src="https://github.com/lkzhao/Hero/blob/master/Resources/basic.png?raw=true" width="548"/>

2. **Using either the StoryBoard's Identity Inspector or by code, set views' heroID**

  <img src="https://github.com/lkzhao/Hero/blob/master/Resources/blue@2x.png?raw=true" width="267"/>

  or

  ```swift
  blueView.heroID = "blue"
  ```
  
  **Remember to set `heroID` to both the source view and the destination view**

3. **Enable Hero Transition to the destination view controller (ViewController2) and UINavigationController if you are using a UINavigationController stack**

  <img src="https://github.com/lkzhao/Hero/blob/master/Resources/ViewController@2x.png?raw=true" width="267"/>
  
  or
  
  ```swift
  viewController2.isHeroEnabled = true
  ```

For detailed explaination about how **Hero ID**, **Hero Modifiers**, and supported animations, read the **[Usage Guide](https://github.com/lkzhao/Hero/wiki/Usage-Guide)**, or download the **[Source Code](http://github.com/lkzhao/Hero/zipball/master/)**.

## License

Hero is available under the MIT license. See the LICENSE file for more info.
