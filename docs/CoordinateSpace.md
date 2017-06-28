### Global Coordinate Space (default before 0.1.3)

Animating views are **not** affected by parent views' attributes. Does not move with the parent view. I.e. They are being taken out of the view hierarchy once heroModifiers are applied. Use `useGlobalCoordinateSpace` modifier to force this behavior after 0.1.3.

<img src="https://cdn.rawgit.com/lkzhao/Hero/ecec15de7747d9541db9af62e4001da6bf0b3896/Resources/globalCoordinate.svg" />

### Local Coordinate Space (default after 0.1.3)

Animating views moves along with its parent view. Note that when a view is matched, or when `source` or `useGlobalCoordinateSpace` modifiers are used, the view will go back to global coordinate space.

<img src="https://cdn.rawgit.com/lkzhao/Hero/ecec15de7747d9541db9af62e4001da6bf0b3896/Resources/localCoordinate.svg" />

For the examples above, the following heroModifiers are applied.

```swift
greyView.heroModifiers = [.translate(y:100)]
blackView.heroModifiers = nil
redView.heroModifiers = [.translate(x:50)]
```

When using local coordinate space, the view is contained inside a global coordinate spaced view. Other global spaced view might appear on top of these local spaced views. If you want a view to appear on top of another global spaced view, you will have to change it to global spaced as well by using the `useGlobalCoordinateSpace` modifier.