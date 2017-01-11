<img src="https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@2x.png?raw=true" width="388"/>

[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/Hero.svg?style=flat)](http://cocoapods.org/pods/Hero)
[![License](https://img.shields.io/cocoapods/l/Hero.svg?style=flat)](https://github.com/lkzhao/Hero/blob/master/LICENSE?raw=true)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

**Hero**是一个iOS界面切换库。它代替了UIKit本身的转场动画接口，使制作自定义的转场动画(View Controller Transition)非常简单！

### 特点
<img src="https://cdn.rawgit.com/lkzhao/Hero/e6c77629fcf2ea1c9b8526f74d250a2fea68ae5c/Resources/basic.svg"/>
<img src="https://cdn.rawgit.com/lkzhao/Hero/b8f01051e9e8ce0cdc8eb7888c6d7ffa2344d96a/Resources/effects.svg"/>

#### 你可以使用这些效果来拼凑出你想要的转场动画。

Hero很像Keynote的[“神奇移动”过渡(Magic Move)](https://support.apple.com/kb/PH16959?locale=zh_CN)。在界面切换时，Hero会把开始界面的视图与结束界面的视图配对，假如他能找到一对儿有着一样的`heroID`的视图的话，Hero便会自动为此视图创建动画，从它一开始的状态移动到结束时的状态。

不仅如此，Hero还可以为没有配对的视图制作动画。每一个视图都可以轻易的用`heroModifiers`来告诉Hero你想为这个视图所创造的动画。交互式动画(interactive transition)也是支持的哟。

Hero还参照Google的[Material Design Motion Guide](https://material.io/guidelines/motion/duration-easing.html)来提供动态的动画长度与时间曲线。你不需要告诉Hero动画的长度与时间曲线，Hero会参照视图的移动长度和大小来自动选择最适合的参数。

无论你使用怎样的方法制作和布局你的视图，Hero都能帮你省去很多时间制作动画。Hero支持 **auto layout**, **programmatic layout**, **UICollectionView**, **UITableView**, **UINavigationController**, **UITabBarController**, 等等。。

## 视频

1. 实例介绍。**Example Project**.
2. 自带的校错程序介绍, 可以显示时间轴，曲线路线，和3D视图。**built-in debugger** 

<a href="https://youtu.be/-6L79or6Iq8"><img src="https://github.com/lkzhao/Hero/blob/master/Resources/overview.png?raw=true" height="300"/></a>
<a href="https://youtu.be/NFhA6qZdunA"><img src="https://github.com/lkzhao/Hero/blob/master/Resources/debugger.png?raw=true" height="300"/></a>

## 安装方法与用法
Hero可以用Carthage或者Cocoapods安装，具体用法请见**[Usage Guide](https://github.com/lkzhao/Hero/wiki/Usage-Guide)**。

##### 注: 因为一个苹果的[bug](https://forums.developer.apple.com/thread/63438)，Hero 不能在iPhone 7 Simulators上使用。 请使用其他版本的Simulator或者使用真机。

## 简单实例 1

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


## 简单实例 2
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

// collectionView 是所有红色视图的父视图
collectionView.heroModifiers = [.cascade]
for cell in redCells {
	cell.heroModifiers = [.fade, .scale(0.5)]
}
```

Hero 还支持 **storyboard**。 你可以在Storyboard右边的Identity Inspector来使用HeroID与HeroModifiers。

<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardView.png" width="267px"/> 
<img src="https://cdn.rawgit.com/lkzhao/Hero/master/Resources/storyboardViewController.png" width="267px"/>

## Contribute

We welcome any contributions. Please read the [Contribution Guide](https://github.com/lkzhao/Hero/wiki/Contribution-Guide).

## License

Hero is available under the MIT license. See the LICENSE file for more info.
