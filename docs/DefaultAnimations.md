# Default Animations

Starting with **0.3.0**. Hero provides several default transitions. These can also be customized & combined with your custom `heroID` & `heroModifiers`. Makes transitions even easier to implement.

<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/defaultAnimations.svg"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://cdn.rawgit.com/lkzhao/Hero/ebb3f2c/Resources/defaultAnimations2.svg"/>

## Methods for changing the default animations

Use the following properties to change default animation type for different presentation methods.

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

## Supported default animations

Please checkout [HeroDefaultAnimations.swift](https://github.com/lkzhao/Hero/blob/master/Sources/HeroDefaultAnimations.swift#L25) for supported animations.

Many of these animations support directions(up, down, left, right).

## .auto Animation Type

`.auto` is the default animation type. It uses the following animations depending on the presentation style:

* `.none` if source root view or destination root view have existing animations (defined via `heroID` or `heroModifiers`).
* `.push` & `.pull` if animating within a UINavigationController.
* `.slide` if animating within a UITabbarController.
* `.fade` if presenting modally.
* `.none` if presenting modally with `modalPresentationStyle == .overFullScreen`.

## .selectBy(presenting:, dismissing:) Animation Type

Will determine the animation type by whether or not we are presenting or dismissing.

For example:

```swift
.selectBy(presenting:.push(.left), dismissing:.pull(.right))
```

Will use left push animation if presenting a VC, or right pull animation when dismissing a VC.

## Note

Other than `.auto` & `.none`, default animations will override `heroModifiers` on source & destination root views during the transition.