# Interactive Transition

#### Check out the [Interactive transitions with Hero (Part 1)](http://lkzhao.com/2017/02/05/hero-interactive-transition.html) blog post for a more in-depth tutorial on interactive transition.


## General Approach

When implementing a interactive transition, the general approach is to setup a gesture recognizer first. Then do the following 3 things inside the gesture handler:

1. Tell Hero when to start the transition

    Usually happens when `gestureRecognizer.state == .began`. Begin the transition as normal.

2. Tell Hero to update the animations through out the transition

    Use `Hero.shared.update(progress:)` & `Hero.shared.apply(modifiers:to:)` to modify the progress & view states.

3. Tell Hero to end/cancel the transition

    Use `Hero.shared.end()` or `Hero.shared.cancel()`


## Interactive methods

`Hero.shared` is the singleton object you can operate with when doing an interactive transition. It has the following 4 methods that are useful for interactive transition:

```swift
/**
 Update the progress for the interactive transition.
 - Parameters:
     - progress: the current progress, must be between 0...1
 */
public func update(progress: Double) 

/**
 Finish the interactive transition.
 Will stop the interactive transition and animate from the
 current state to the **end** state
 */
public func end(animate: Bool = true)

/**
 Cancel the interactive transition.
 Will stop the interactive transition and animate from the 
 current state to the **beginning** state
 */
public func cancel(animate: Bool = true)

/**
 Override modifiers during an interactive animation.
 
 For example:
 
     Hero.shared.apply([.position(x:50, y:50)], to:view)
 
 will set the view's position to 50, 50
 - Parameters:
     - modifiers: the modifiers to override
     - view: the view to override to
 */
public func apply(modifiers: [HeroModifier], to view: UIView)
```

## Sample Gesture Recognizer Handler

This example is taken from `ImageViewController.swift` inside the example project.

```swift
  func pan() {
    let translation = panGR.translation(in: nil)
    let progress = translation.y / 2 / collectionView!.bounds.height
    switch panGR.state {
    case .began:
      Hero.shared.setDefaultAnimationForNextTransition(.fade)
      hero_dismissViewController()
    case .changed:
      Hero.shared.update(progress: Double(progress))
      if let cell = collectionView?.visibleCells[0]  as? ScrollingImageCell {
        let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
        Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.imageView)
      }
    default:
      if progress + panGR.velocity(in: nil).y / collectionView!.bounds.height > 0.3 {
        Hero.shared.end()
      } else {
        Hero.shared.cancel()
      }
    }
  }
```

