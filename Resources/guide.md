<img src="https://github.com/lkzhao/Hero/blob/master/Resources/HeroLogo@4x.png?raw=true" width="388"/>

# Usage Guide

## Installation

#### Manual

Drag the `Hero` folder into your project. [(Download)](http://github.com/lkzhao/Hero/zipball/master/Hero)

#### CocoaPods

`pod "Hero"`

## Usage
### Storyboard

1. In the Identity Inspector, for every pair of source/destination views, give them the same `HeroID` attribute.
3. For any other views that you would like to animate, specify the animation effects in `HeroModifiers` attribute.
4. Also in the Identity Inspector. Enable Hero Transition on your destination view controller.

### In Code

1. Before doing a transition, set the desired `heroID` & `HeroModifiers` to source & destination views.
2. Enables Hero for the destination view controller

  ```swift
    viewController.isHeroEnabled = true
  ```

## Attributes
There are two important attributes to understand, `HeroID` and `HeroModifiers`. These are implemented as extensions(using associated objects) for `UIView`. Therefore, after the Hero library is imported, every `UIView` will have these two attributes. Both can be accessed from the Identity Inspector.

| Attribute Name | Description |
| --- | --- |
| `HeroID`    | Identifier for the view. Hero will automatically transition between views with the same `HeroID` |
| `HeroModifiers` | Specifies the extra animations performed alongside the main transition. |

## HeroID

`HeroID` is the identifier for the view. When doing a transition between two view controllers,
Hero will search through all the subviews for both view controllers and matches views with the same `HeroID`. Whenever a pair is discovered,
Hero will automatically transition the views from source state to the destination state.

## HeroModifiers

Use `HeroModifiers` to specify animations alongside the main transition. It must be in the following syntax:

```swift
modifier1() modifier2(parameter1) modifier3(parameter1, parameter2) ...
```

Modifiers can have parameters. Parameters must be between a pair of parentheses, seperated by a comma. 
Each modifier must be seperated by a space.
Parameters can be string or number(float, int, & negative).

#### For example, to achieve the following effect, set the `heroModifiers` to be

```swift
fade() translate(0, -250) rotate(-1.6, 0, 0) scale(1.5)
```

<img src="https://github.com/lkzhao/Hero/blob/master/Resources/heroTransition.gif?raw=true" width="300">

### Supported Modifiers

#### Basic Modifiers
| Modifier Name | Description |
| --- | --- |
| fade             | Fade in or out when transitioning     |
| position(x,y)    | Transition to a position              |
| bounds(x,y,w,h)  | Transition to a bounds                |
| scale(s)         | Scale along both x & y axis           |
| scale(x,y,z)     | Scale in 3d                           |
| rotate(z)        | Rotate in 2d                          |
| rotate(x,y,z)    | Rotate in 3d                          |
| perpective(z)    | Set the transform's perspective       |
| translate(x,y,z) | Translate in 3d                       |

#### Advance Modifiers

| Modifier Name | Description |
| --- | --- |
| delay(time)                               | Delay for the animation               |
| duration(time)                            | Duration for the animation      |
| curve(curveName)                          | Timing function for the animation (linear, easeIn, easeOut, easeInOut) |
| curve(c1x, c1y, c2x, c2y)                 | Custom cubic bezier timing function for the animation |
| spring(stiffness, damping)                | **(iOS 9+)** Use spring animation with custom stiffness & damping. The duration will be automatically calculated. (This modifier has no effect when `curve` or `duration` modifier is used) |
| zPosition(z)                              | The z axis height of the view during the animation phase. Not animatable. |
| zPositionIfMatched(z)                     | The z axis height of the view during the animation phase if being matched with another view by `HeroID`. Not animatable. |
| sourceID(HeroID)                          | Transition from a view with given heroID |
| cascade(deltaDelay, direction, delay, forceMatchedToWait)        | Apply increasing delay to view's subview |
| clearSubviewModifiers                      | Disables all `heroModifiers` for view's direct subviews |

#### SourceID Modifier
The `sourceID` modifier allows a view to be transitioned from a view with the matching heroID.

##### See the Menu Example for how `sourceID` is used.

#### Cascade Modifier

The `cascade` modifier automatically applies increasing `delay` heroModifiers to a view's direct subviews.

##### See the ListToGrid & ImageGallery Example for how `cascade` is used.

#### clearSubviewModifiers Modifier

The `clearSubviewModifiers` modifier disables all `heroModifiers` attributes for a view's direct subviews.
