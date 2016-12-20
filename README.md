<img src="https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@2x.png?raw=true" width="388"/>

Supercharged transition engine for iOS. Build your custom view transitions with few lines of code or even no code at all. Inspired by Polymer's [neon-animated-pages](https://elements.polymer-project.org/elements/neon-animation) and Keynote's `Magic Move`.

[![Version](https://img.shields.io/cocoapods/v/Hero.svg?style=flat)](http://cocoapods.org/pods/Hero)
[![License](https://img.shields.io/cocoapods/l/Hero.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/LICENSE?raw=true)
![Xcode 8.0+](https://img.shields.io/badge/XCode-8.0%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

## Video Demo
**[View here](https://youtu.be/-6L79or6Iq8)**

## Usage Guide
**[Read here](https://github.com/lkzhao/Hero/wiki/Usage-Guide)**

## What is Hero?

Hero is a library for building iOS view controller transitions. It provides extensions and an API layer on top of the UIKit's cumbersome transition APIs. Making custom transitions a easy task for developers.

At its core, Hero provides a automatic transition similar to Keynote's `Magic Move`. It does this by checking the `heroID` property on both view controllers' subviews. Every matched view pairs are then automatically transitioned from it's old state to it's new state.

Hero is also able to construct animations for other views that are not matched. It is super easy to define those animations via the `heroModifiers` property. and Hero will run these animations alongside the `Magic Move` animations. Not only that, Hero is able to handle everything interactively, too.

Hero does all of these without any assumption about how the view is built or structured. It will not modify any of your views' states other than hidding them during the animation. This means that it works great with autolayout, programmatic layout, UICollectionView, UITableView, UINavigationController etc... 

## Tl;dr: This is what Hero does:
* Automatically transition matched views between view controllers
* Built in animations for unmatched views:
  * Fade
  * Scale
  * Rotate
  * Translate
  * Position
  * Bounds
* Attributes to tweak animation properties for each views independently
  * Easing (Timing Functions)
  * Spring Damping
  * Spring Stiffness
* Works with
  * Autolayout
  * Programmatic Layout
  * UINavigationController
  * UITableView
  * UICollectionView (without messing with UICollectionViewLayout)
* Apply `cascade` effects to these animations
* Super slim API for making all of these interactive!

## Quick Guide

### Basic HeroID Tutorial
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

3. **Enable Hero Transition to the destination view controller (ViewController2)**

  <img src="https://github.com/lkzhao/Hero/blob/master/Resources/ViewController@2x.png?raw=true" width="267"/>
  
  or
  
  ```swift
  viewController2.isHeroEnabled = true
  ```

#### More to come

For detailed explaination about how **Hero ID**, **Hero Modifiers**, and supported animations, read the **[Usage Guide](https://github.com/lkzhao/Hero/wiki/Usage-Guide)**, or download the **[Source Code](http://github.com/lkzhao/Hero/zipball/master/)**.

## License

Hero is available under the MIT license. See the LICENSE file for more info.
