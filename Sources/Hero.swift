// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/**
 ### The singleton class/object for controlling interactive transitions.
 
 ```swift
   Hero.shared
 ```
 
 #### Use the following methods for controlling the interactive transition:

 ```swift
   func update(progress:Double)
   func end()
   func cancel()
   func apply(modifiers:[HeroModifier], to view:UIView)
 ```
 */
public class Hero: HeroBaseController {
  // MARK: Shared Access

  /// Shared singleton object for controlling the transition
  public static let shared = Hero()
  
  // MARK: Properties

  /// destination view controller
  public internal(set) var toViewController: UIViewController?
  /// source view controller
  public internal(set) var fromViewController: UIViewController?
  /// whether or not we are presenting the destination view controller
  public fileprivate(set) var presenting = true

  /// progress of the current transition. 0 if no transition is happening
  public override var progress: Double {
    didSet {
      if transitioning {
        transitionContext?.updateInteractiveTransition(CGFloat(progress))
      }
    }
  }
  
  /// a UIViewControllerContextTransitioning object provided by UIKit,
  /// might be nil when transitioning. This happens when calling heroReplaceViewController
  fileprivate weak var transitionContext: UIViewControllerContextTransitioning?

  internal var completionCallback: ((Bool) -> Void)?

  fileprivate var inNavigationController = false
  fileprivate var inTabBarController = false
  fileprivate var inContainerController:Bool {
    return inNavigationController || inTabBarController
  }
  
  fileprivate var toView: UIView { return toViewController!.view }
  fileprivate var fromView: UIView { return fromViewController!.view }
  
  fileprivate override init() {}
}

// internal methods for transition
internal extension Hero {
  func start() {
    guard transitioning else { return }
    if let fvc = fromViewController, let tvc = toViewController {
      closureProcessForHeroDelegate(vc: fvc) {
        $0.heroWillStartTransition?()
        $0.heroWillStartAnimatingTo?(viewController: tvc)
      }
      
      closureProcessForHeroDelegate(vc: tvc) {
        $0.heroWillStartTransition?()
        $0.heroWillStartAnimatingFrom?(viewController: fvc)
      }
    }

    prepareForTransition()
    
    // take a snapshot to hide all the flashing that might happen
    let completeSnapshot = fromView.snapshotView(afterScreenUpdates: true)!
    transitionContainer.addSubview(completeSnapshot)

    context = HeroContext(container:container)

    context.hide(view: toView)
    container.addSubview(toView)
    container.addSubview(fromView)

    toView.frame = fromView.frame
    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()

    context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)

    for processor in processors {
      processor.process(fromViews: context.fromViews, toViews: context.toViews)
    }

    var skipDefaultAnimation = false
    var animatingViews = [([UIView], [UIView])]()
    for animator in animators {
      let currentFromViews = context.fromViews.filter { (view: UIView) -> Bool in
        return animator.canAnimate(view: view, appearing: false)
      }
      let currentToViews = context.toViews.filter { (view: UIView) -> Bool in
        return animator.canAnimate(view: view, appearing: true)
      }
      if currentFromViews.first == fromView || currentToViews.first == toView {
        skipDefaultAnimation = true
      }
      animatingViews.append((currentFromViews, currentToViews))
    }
    
    if !skipDefaultAnimation {
      // if no animator can animate toView & fromView, set the effect to fade // i.e. default effect
      context[toView] = [.fade]
      animatingViews[0].1.insert(toView, at: 0)

      #if os(tvOS)
        context[fromView] = [.fade]
        animatingViews[0].0.insert(fromView, at: 0)
      #endif

      if toView.layer.zPosition < fromView.layer.zPosition {
        // in this case, we have to animate the zPosition as well. otherwise the fade animation will be hidden.
        context[toView]!.append(.zPosition(fromView.layer.zPosition + 1))
        if context[fromView] == nil {
          context[fromView] = []
        }
        context[fromView]!.append(.zPosition(toView.layer.zPosition - 1))
        if animatingViews[0].0.first != fromView {
          animatingViews[0].0.insert(fromView, at: 0)
        }
      }
    }

    func animate() {
      context.unhide(view: toView)
      container.backgroundColor = toView.backgroundColor
      for (currentFromViews, currentToViews) in animatingViews {
        // auto hide all animated views
        for view in currentFromViews {
          context.hide(view: view)
        }
        for view in currentToViews {
          context.hide(view: view)
        }
      }

      var totalDuration: TimeInterval = 0
      var animatorWantsInteractive = false
      for (i, animator) in animators.enumerated() {
        let duration = animator.animate(fromViews: animatingViews[i].0,
                                        toViews: animatingViews[i].1)
        if duration == .infinity {
          animatorWantsInteractive = true
        } else {
          totalDuration = max(totalDuration, duration)
        }
      }

      if !skipDefaultAnimation {
        // change the duration of the default fade animation to be the total duration of the animation
        animators.first?.apply(state: [.duration(totalDuration)], to: toView)
      }

      // we are done with setting up, so remove the covering snapshot
      completeSnapshot.removeFromSuperview()
      self.totalDuration = totalDuration
      if animatorWantsInteractive {
        update(progress: 0.001)
      } else {
        complete(after: totalDuration, finishing: true)
      }
    }

    #if os(tvOS)
      animate()
    #else
      if inContainerController && presenting {
        // When animating within navigationController, we have to dispatch later in the runloop. 
        // otherwise snapshots will not be taken. Possibly a bug with UIKit
        DispatchQueue.main.async {
          animate()
        }
      } else {
        animate()
      }
    #endif
  }

  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
    guard !transitioning else { return }
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
  }

  override func complete(finished: Bool) {
    guard transitioning else { return }

    // move fromView & toView back from our container back to the one supplied by UIKit
    transitionContainer.addSubview(finished ? toView : fromView)
    
    // use temp variables to remember these values
    // because we have to reset everything before calling
    // any delegate or completion block
    let tContext = transitionContext
    let completion = completionCallback
    let fvc = fromViewController
    let tvc = toViewController

    transitionContext = nil
    completionCallback = nil
    fromViewController = nil
    toViewController = nil
    inNavigationController = false
    inTabBarController = false
    forceNotInteractive = false

    super.complete(finished: finished)

    if finished {
      if let fvc = fvc, let tvc = tvc {
        closureProcessForHeroDelegate(vc: fvc) {
          $0.heroDidEndAnimatingTo?(viewController: tvc)
          $0.heroDidEndTransition?()
        }

        closureProcessForHeroDelegate(vc: tvc) {
          $0.heroDidEndAnimatingFrom?(viewController: fvc)
          $0.heroDidEndTransition?()
        }
      }
      tContext?.finishInteractiveTransition()
    } else {
      if let fvc = fvc, let tvc = tvc {
        closureProcessForHeroDelegate(vc: fvc) {
          $0.heroDidCancelAnimatingTo?(viewController: tvc)
          $0.heroDidCancelTransition?()
        }

        closureProcessForHeroDelegate(vc: tvc) {
          $0.heroDidCancelAnimatingFrom?(viewController: fvc)
          $0.heroDidCancelTransition?()
        }
      }
      tContext?.cancelInteractiveTransition()
    }
    tContext?.completeTransition(finished)
    completion?(finished)
  }
}

// delegate helper
fileprivate extension Hero {
  func closureProcessForHeroDelegate<T: UIViewController>(vc: T, closure: (HeroViewControllerDelegate)->()) {
    if let delegate = vc as? HeroViewControllerDelegate {
      closure(delegate)
    }
    
    if let navigationController = vc as? UINavigationController,
       let delegate = navigationController.topViewController as? HeroViewControllerDelegate {
      closure(delegate)
    }
    
    if let tabBarController = vc as? UITabBarController,
       let delegate = tabBarController.viewControllers?[tabBarController.selectedIndex] as? HeroViewControllerDelegate {
      closure(delegate)
    }
  }
}










// MARK: UIKit Protocol Conformance

/*****************************
 * UIKit protocol extensions *
 *****************************/

extension Hero: UIViewControllerAnimatedTransitioning {
  public func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard !transitioning else { return }
    transitionContext = context
    fromViewController = fromViewController ?? context.viewController(forKey: .from)
    toViewController = toViewController ?? context.viewController(forKey: .to)
    transitionContainer = context.containerView
    start()
  }
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.375 // doesn't matter, real duration will be calculated later
  }
}

extension Hero:UIViewControllerTransitioningDelegate {
  var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
    return forceNotInteractive ? nil : self
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    self.fromViewController = fromViewController ?? presenting
    self.toViewController = toViewController ?? presented
    return self
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = false
    self.fromViewController = fromViewController ?? dismissed
    return self
  }

  public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }

  public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension Hero: UIViewControllerInteractiveTransitioning {
  public var wantsInteractiveStart: Bool {
    return true
  }
  public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    animateTransition(using: transitionContext)
  }
}

extension Hero: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = operation == .push
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inNavigationController = true
    return self
  }

  public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension Hero: UITabBarControllerDelegate {
  public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }

  public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inTabBarController = true
    return self
  }
}
