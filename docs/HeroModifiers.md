#### Checkout [HeroModifier.swift](https://github.com/lkzhao/Hero/blob/master/Sources/HeroModifier.swift) for up-to-date modifier details.

### Basic Modifiers
* fade
* position
* size
* scale
* rotate
* perspective
* translate
* zPosition
* opacity
* shadowOpacity
* shadowRadius
* shadowColor
* shadowOffset
* shadowPath
* borderColor
* borderWidth

### Advance Modifiers

| Modifier Name | Description |
| --- | --- |
| delay(time)                               | Delay for the animation               |
| duration(time)                            | Duration for the animation, if unspecified, the duration will be calculated based on the distance travelled |
| timingFunction(curveName)                          | Timing function for the animation (`linear`, `easeIn`, `easeOut`, `easeInOut`, `standard`, `deceleration`, `acceleration`, `sharp`) |
| timingFunction(c1x, c1y, c2x, c2y)                 | Custom cubic bezier timing function for the animation |
| spring(stiffness, damping)                | **(iOS 9+)** Use spring animation with custom stiffness & damping. The duration will be automatically calculated. Will be ignored if `arc`, `curve`, or `duration` is set. |
| useGlobalCoordinateSpace                  | Force the view to use global coordinate space |
| overlay(color:,opacity)                   | Animate an overlay on top of the view |
| source(HeroID)                            | Transition from a view with given heroID |
| arc(intensity)                            | Make position animation follow a natural arc curve. |
| cascade(deltaDelay, direction, forceMatchedToWait)        | Apply increasing delay to view's subview |
| ignoreSubviewModifiers                    | Disables all `heroModifiers` for view's direct subviews |
| useScaleBasedSizeChange | Force Hero use scale based size animation. |
| useOptimizedSnapshot | Change snapshot type to OptimizedSnapshot, see [Snapshot Types](#snapshot-types) |
| useNormalSnapshot | Change snapshot type to NormalSnapshot, see [Snapshot Types](#snapshot-types) |
| useLayerRenderSnapshot | Change snapshot type to LayerRenderSnapshot, see [Snapshot Types](#snapshot-types) |
| useNoSnapshot | Change snapshot type to NoSnapshot, see [Snapshot Types](#snapshot-types) |
| beginWith(modifiers:) | Apply modifiers directly to the view at the start of the transition. Without animation. |
| beginWithIfMatched(modifiers:) | Same as `beginWith` but effective only when matched. |

#### Modifiers Support for matched views
Some of the modifiers **won't** work with matched views(views with the same `heroID`). These are:
* fade
* scale
* translate
* rotate
* transform
* cascade

NOTE: For other modifiers that works with matched views, the target view's modifiers will be used. the source view's modifiers will be ignored.

## Modifier Details

### Arc Modifier
When animating `position`, if **arc** is enabled. the view will follow a natural arc curve instead of going to the target position directly. See [material design](https://material.io/guidelines/motion/movement.html#movement-movement-within-screen-bounds) for more details.

The **intensity** parameter is a number that determine the curve's intensity. A value of 0 means no curve. A value of 1 means a natural downward curve. This value can be negative or above 1. Default is 1.

Use the debug plugin and enable **Show Curves** to see the actual arc curve objects follows.

### Source Modifier
The `source` modifier allows a view to be transitioned from a view with the given heroID.

##### See the Menu Example for how `source` is used.

### Cascade Modifier

The `cascade` modifier automatically applies increasing `delay` heroModifiers to a view's direct subviews.

| Parameters | Description |
| --- | --- |
| deltaDelay | delay in between each animation |
| direction | the cascade direction, can be `topToBottom`, `bottomToTop`, `leftToRight`, & `rightToLeft`, default `topToBottom` |
| forceMatchedToWait | whether or not to delay matched views until all cascading animations have started, default false |

NOTE: matched views(views with the same `heroID`) won't have the cascading effect. however, you can use the 3rd parameter to delay the start time of matched views until the last cascading animation have started. The matched views will animate simultaneously with the cascading views by default.

##### See the ListToGrid & ImageGallery Example for how `cascade` is used.

### ignoreSubviewModifiers Modifier

The `ignoreSubviewModifiers` modifier disables all `heroModifiers` attributes for a view's direct subviews.

### useScaleBasedSizeChange Modifier

Force Hero use scale based size animation. This will convert all `.size` modifier into `.scale` modifier.
This is to help Hero animate layers that doesn't support bounds animation. Also gives better animation performance.