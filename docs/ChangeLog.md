## 0.3.2
* new properties for specifying default animations
```swift
extension UIViewController {
  /// default hero animation type for presenting & dismissing modally
  public var heroModalAnimationType: HeroDefaultAnimationType
}
extension UINavigationController {
  /// default hero animation type for push and pop within the navigation controller
  public var heroNavigationAnimationType: HeroDefaultAnimationType
}
extension UITabBarController {
  /// default hero animation type for switching tabs within the tab bar controller
  public var heroTabBarAnimationType: HeroDefaultAnimationType
}
```
* bug fixes https://github.com/lkzhao/Hero/issues/90 https://github.com/lkzhao/Hero/issues/85
* basic support for animating UIVisualEffectView's effect property in iOS 10

## 0.3.0
* support `.overFullScreen` modalPresentationStyle
* Implement many new default transitions. (fade was the only default transition before this update)

  * **.push(direction: Direction)**
  * **.pull(direction: Direction)**
  * **.cover(direction: Direction)**
  * **.uncover(direction: Direction)**
  * **.slide(direction: Direction)**
  * **.zoomSlide(direction: Direction)**
  * **.pageIn(direction: Direction)**
  * **.pageOut(direction: Direction)**

* a few new modifiers:
  * **beginWith(modifiers:[HeroModifier])**
  * **durationMatchLongest**
  * **overlay(color:UIColor, opacity:CGFloat)**
  * **masksToBounds(_ masksToBounds: Bool)**

## 0.1.7
* fix a zPosition regression introduced in 0.1.5

## 0.1.6
* fix a regression introduced in 0.1.5 where animation for matched view might appear inconsistent.

## 0.1.5
* fix a bug where toViewController's delegate callbacks are not being called
* fix a bug where fromViewController's delegate callbacks receive incorrect parameters.
* Add **useScaleBasedSizeChange** modifier.
    Force Hero use scale based size animation. This will convert all `.size` modifier into `.scale` modifier.
    This is to help Hero animate layers that doesn't support bounds animation. Also gives better performance when animating.

* fix a few bugs with `.useNoSnapshot`
* new video player example.

## 0.1.4
* fix a bug where changing orientation doesn't affect previous VC. https://github.com/lkzhao/Hero/issues/60
* fix a bug where the presented view controller has incorrect frame. https://github.com/lkzhao/Hero/issues/63, https://github.com/lkzhao/Hero/issues/56
* New **snapshot type** modifiers:
  * **useOptimizedSnapshot**
    
     With this modifier, Hero will create snapshot optimized for different view type when animating.
     For custom views or views with masking, useOptimizedSnapshot might create snapshots
     that appear differently than the actual view.
     In that case, use .useNormalSnapshot or .useSlowRenderSnapshot to disable the optimization.
  * **useNormalSnapshot**

     Create snapshot using snapshotView(afterScreenUpdates:).
  * **useLayerRenderSnapshot**

     Create snapshot using layer.render(in: currentContext).
     This is slower than .useNormalSnapshot but gives more accurate snapshot for some views (eg. UIStackView).
  * **useNoSnapshot**

     Force Hero to not create any snapshot when animating this view. Hence Hero will animate on the view directly.
     This will mess up the view hierarchy. Therefore, view controllers have to rebuild its view structure after the transition finishes.

* New navigation extension on UIViewController (mainly to support **unwinding**):
  * **func hero_dismissViewController()**

     Dismiss the current view controller with animation. Will perform a navigationController.popViewController 
     if the current view controller is contained inside a navigationController.
  * **func hero_replaceViewController(with:UIViewController)**

     Replace the current view controller with another VC on the navigation/modal stack.
  * **func hero_unwindToRootViewController()**

     Unwind to the root view controller using Hero.
  * **func hero_unwindToViewController(_ toViewController:)**

     Unwind to a specific view controller using Hero.
  * **func hero_unwindToViewController(withSelector: Selector)**

     Unwind to a view controller that responds to the given selector using Hero.
  * **func hero_unwindToViewController(withClass: AnyClass)**

     Unwind to a view controller with given class using Hero.
  * **func hero_unwindToViewController(withMatchBlock: (UIViewController) -> Bool)**

     Unwind to a view controller that the match block returns true on.

## 0.1.3
* Support **local coordinate space**.

    | Global coordinate space | Local (parent's) coordinate space |
    | ---- | ---- |
    | Animating views are **not** affected by parent views' attributes | Animating views are affected by parent views' attributes |
    | When parent view moves, subviews that have its own modifiers do **not** move with the parent view. I.e. they are being taken out of the view hierarchy. | When parent view moves, subviews that have its own modifiers move along with the parent view. I.e. similar to how a view behave when its parent view moves.  |
    | Used for matched views & views with `source` modifier. Global is the default prior to 0.1.3 | Local is the default coordinate space after 0.1.3 |

* New **useGlobalCoordinateSpace** modifier. Force the view to use global coordinate space. I.e. won't move with its parent view.

## 0.1.2
* `HeroPlugin` returning .infinity duration will be treated as wanting interactive transition
* few bug fixes.
* Update plugin API protocol to be more concise.

## 0.1.1
* Swift Package Manager Support, Thanks to [@mRs-](https://github.com/mRs-)
* Bug fixes #41, #36, & #38
* Cleaner navigation bar animation.
* Better alpha animation support.

## 0.1.0
* add **HeroModifier** class and **HeroTargetState** struct
  * **HeroModifier** is a swift enum-like class that provides the same functionality of the original string-based **heroModifiers**.
  * **HeroTargetState** is a struct that holds view state informations. It can be build from **[HeroModifier]**. Mostly used internally and for building **HeroPlugin**.
* change the original `heroModifiers:String?` to `heroModifierString:String?` **(breaking change!)**
* add `heroModifiers:[HeroModifier]?` to **UIView**
* add a shared singleton `Hero` object for controlling the interactive transition. Which can be accessed by `Hero.shared`
* few changes to the protocols 
  * protocol **HeroAnimator**

     ```swift
     func temporarilySet(view:UIView, to modifiers:HeroModifiers)
     // to 
     func temporarilySet(view:UIView, targetState:HeroTargetState)
     ```
  * protocol **HeroViewControllerDelegate**

     ```swift
     @objc optional func wantInteractiveHeroTransition(context:HeroInteractiveContext) -> Bool
     // to
     @objc optional func wantInteractiveHeroTransition() -> Bool
     ```
  * remove **HeroInteractiveContext** protocol
* update **HeroPlugin** to conform to the new protocols definitions.
* rename a few modifiers:
  * **curve** → **timingFunction**
  * **sourceID** → **source**
  * **clearSubviewModifiers** → **ignoreSubviewModifiers**
* fix a bug with `heroReplaceViewController` API. [PR 30](https://github.com/lkzhao/Hero/pull/30)
* fix a bug with **UIStackView** not animating correctly. [PR 22](https://github.com/lkzhao/Hero/pull/22)
* add **recursive** `ignoreSubviewModifiers` modifier
* add **radial** & **inverseRadial** cascade:

    <img src="https://cloud.githubusercontent.com/assets/3359850/21759371/a95e0bea-d5f8-11e6-8568-d0e02ef2b6fe.gif" width="200" />

### To migrate from previous versions:

Do a whole-project **find & replace**(cmd+option+shift+F) for:

  * **heroModifiers** → **heroModifierString**
  * **curve** → **timingFunction**
  * **sourceID** → **source**
  * **clearSubviewModifiers** → **ignoreSubviewModifiers**

 Remember to also replace these inside the storyboard. In code, please migrate to the new type-safe `heroModifiers`. It provides better type-checking and more functionality.

## 0.0.5
* Add live injection example
* Make `snapshotView` available to all HeroAnimators.
* Add `heroWillStartTransition` & `heroDidEndTransition` callbacks to `HeroViewControllerDelegate`
* Fix animation for UIStackView https://github.com/lkzhao/Hero/pull/18
* Smoother UIImageView animation for bounds change https://github.com/lkzhao/Hero/pull/16

## 0.0.4
* Add Carthage support

## 0.0.3
* Cleaner resume animation after an interactive transition.
* plugin API: `seekTo(progress:Double)` changed to `seekTo(timePassed:TimeInterval)`
* plugin API: `resume(progress:Double, reverse:Bool)` changed to `resume(timePassed:TimeInterval, reverse:Bool)`
* provides dynamic duration by default.
  [material design(duration & timing)](https://material.io/guidelines/motion/duration-easing.html#duration-easing-dynamic-durations)

## 0.0.2
* rename `clearSubviewClasses` to `clearSubviewModifiers`. was a naming mistake.
* set default animation to be CABasicAnimation with the **Standard Curve** from [material design (easing)](https://material.io/guidelines/motion/duration-easing.html#duration-easing-natural-easing-curves).
* add the new **arc** effect from [material design (movement)](https://material.io/guidelines/motion/movement.html#movement-movement-within-screen-bounds).
* add **arc** effect to **Basic**, **Menu**, & **ListToGrid** examples.
* add the ability to show arc path in the Debug Plugin.
* ignore `HeroModifiers` for source view when matched with a target view with the same `HeroID`
* some small optimization & bug fixes