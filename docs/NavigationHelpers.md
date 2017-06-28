# Navigation Helper

Hero provides some useful navigation extension methods on UIViewController. Use these alongside with `pushViewController`, `presentViewController` to navigate between view controllers.


```swift
func hero_dismissViewController()
```

Dismiss the current view controller with animation. Will perform a navigationController.popViewController 
if the current view controller is contained inside a navigationController.

```swift
func hero_replaceViewController(with: UIViewController)
```

Replace the current view controller with another VC on the navigation/modal stack.


```swift
func hero_unwindToRootViewController()
```

Unwind to the root view controller using Hero.


```swift
func hero_unwindToViewController(_ toViewController:)
```

Unwind to a specific view controller using Hero.


```swift
func hero_unwindToViewController(withSelector: Selector)
```

Unwind to a view controller that responds to the given selector using Hero.


```swift
func hero_unwindToViewController(withClass: AnyClass)
```

Unwind to a view controller with given class using Hero.


```swift
func hero_unwindToViewController(withMatchBlock: (UIViewController) -> Bool)
```

Unwind to a view controller that the match block returns true on.