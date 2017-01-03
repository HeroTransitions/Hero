<img src="https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@2x.png?raw=true" width="388"/>

Supercharged transition engine for iOS. Build your custom view transitions with few lines of code or even no code at all. Inspired by Polymer's [neon-animated-pages](https://elements.polymer-project.org/elements/neon-animation) and Keynote's `Magic Move`.

[![Version](https://img.shields.io/cocoapods/v/Hero.svg?style=flat)](http://cocoapods.org/pods/Hero)
[![License](https://img.shields.io/cocoapods/l/Hero.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/LICENSE?raw=true)
![Xcode 8.0+](https://img.shields.io/badge/Xcode-8.0%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

## Introduction

**Hero** is a library for building iOS view controller transitions. It provides a layer on top of the UIKit's cumbersome transition APIs. Making custom transitions an easy task for developers.

### Features
<img src="https://cdn.rawgit.com/lkzhao/Hero/e6c77629fcf2ea1c9b8526f74d250a2fea68ae5c/Resources/basic.svg"/>
<img src="https://cdn.rawgit.com/lkzhao/Hero/b8f01051e9e8ce0cdc8eb7888c6d7ffa2344d96a/Resources/effects.svg"/>

#### With Hero, you can easily mix & match these effects to build your own custom transition.

At its core, Hero is similar to Keynote's `Magic Move`. It checks the `heroID` property on all source and destinations views. Every matched view pairs are then automatically transitioned from it's old state to it's new state.

Hero can also construct animations for unmatched views. It is easy to define these animations via the `heroModifiers` property. Hero will run these animations alongside the `Magic Move` animations. All of these can by interactive, too.

Hero does not make any assumption about how the view is built or structured. It will not modify any of your views' states other than hidding them during the animation. This means that it works with autolayout, programmatic layout, UICollectionView, UITableView, UINavigationController etc... 

##### NOTE: Hero won't work on iPhone 7 Simulators due to a [bug](https://forums.developer.apple.com/thread/63438) by Apple. Try using other simulators or a real device when working with Hero.

## Video Demo (Example Project)
**[View here](https://youtu.be/-6L79or6Iq8)**

## Usage Examples

<img src="https://cdn.rawgit.com/lkzhao/Hero/e6c77629fcf2ea1c9b8526f74d250a2fea68ae5c/Resources/simple.svg"/>
<img src="https://cdn.rawgit.com/lkzhao/Hero/e6c77629fcf2ea1c9b8526f74d250a2fea68ae5c/Resources/advance.svg"/>

You can do these in the storyboard too!

<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardViewController.png" width="267px"/>

<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardView.png" width="267px"/>

For detailed explaination about **Hero ID**, **Hero Modifiers**, and supported animations:

#### Read the **[detailed usage guide](https://github.com/lkzhao/Hero/wiki/Usage-Guide)**

This library is completely new and under heavy development. Might not be stable for production use, but there will be more things to come.

## License

Hero is available under the MIT license. See the LICENSE file for more info.
