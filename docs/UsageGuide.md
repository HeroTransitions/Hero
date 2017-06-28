# Usage

### Storyboard

1. In the Identity Inspector, for every pair of source/destination views, give them the same `HeroID` attribute.
3. For any other views that you would like to animate, specify the animation effects in `Hero Modifier String` attribute.
4. Also in the Identity Inspector. Enable Hero Transition on your destination view controller.

### In Code

1. Before doing a transition, set the desired `heroID` & `heroModifiers` to source & destination views.
2. Enables Hero for the destination view controller

  ```swift
    viewController.isHeroEnabled = true
  ```

### UINavigationController & UITabBarController

Hero also support transitions within a navigation controller or a tab bar controller.
Just set the 'isHeroEnabled' attribute to true on the UINavigationController/UITabBarController instance.

## Attributes
There are two important attributes to understand, `heroID` and `heroModifiers`. These are implemented as extensions(using associated objects) for `UIView`. Therefore, after the Hero library is imported, every `UIView` will have these two attributes.

| Attribute Name | Description |
| --- | --- |
| `heroID`    | Identifier for the view. Hero will automatically transition between views with the same `heroID` |
| `heroModifiers` | Specifies the extra animations performed alongside the main transition. |

## HeroID

`heroID` is the identifier for the view. When doing a transition between two view controllers,
Hero will search through all the subviews for both view controllers and matches views with the same `heroID`. Whenever a pair is discovered,
Hero will automatically transit the views from source state to the destination state.

## HeroModifiers

Use `heroModifiers` to specify animations alongside the main transition. Checkout [HeroModifier.swift](https://github.com/lkzhao/Hero/blob/master/Sources/HeroModifier.swift) for available modifiers.

#### For example, to achieve the following effect, set the `heroModifiers` to be

```swift
view.heroModifiers = [.fade, .translate(x:0, y:-250), .rotate(x:-1.6), .scale(1.5)]
```

<img src="https://github.com/lkzhao/Hero/blob/master/Resources/heroTransition.gif?raw=true" width="300">

Note: For matched views, the target view's heroModifier will be used. The source view's heroModifier will be ignored. When dismissing, the target view is the presentingViewController's view and the source view is the presentedViewController's view.

## HeroModifierString

This is a string value. It provides another way to set `heroModifiers`. It can be accessed through the storyboard.

It must be in the following syntax:

```swift
modifier1() modifier2(parameter1) modifier3(parameter1, parameter2) ...
```

Parameters must be between a pair of parentheses, separated by a comma. 
Each modifier must be separated by a space. Not all modifiers are settable by this.
