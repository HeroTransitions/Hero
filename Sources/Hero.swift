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

  fileprivate var fullScreenSnapshot: UIView!
  public var skipDefaultAnimation = false
  public var containerColor: UIColor?

  // By default, Hero will always appear to be interactive to UIKit. This forces it to appear non-interactive.
  // Used when doing a hero_replaceViewController within a UINavigationController, to fix a bug with
  // UINavigationController.setViewControllers not able to handle interactive transition
  internal var forceNotInteractive = false

  fileprivate var inNavigationController = false
  fileprivate var inTabBarController = false
  fileprivate var inContainerController:Bool {
    return inNavigationController || inTabBarController
  }
  fileprivate var toOverFullScreen:Bool {
    return !inContainerController && toViewController!.modalPresentationStyle == .overFullScreen
  }
  fileprivate var fromOverFullScreen:Bool {
    return !inContainerController && fromViewController!.modalPresentationStyle == .overFullScreen
  }
  
  fileprivate var toView: UIView { return toViewController!.view }
  fileprivate var fromView: UIView { return fromViewController!.view }
  
  fileprivate override init() { super.init() }
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

    // take a snapshot to hide all the flashing that might happen
    fullScreenSnapshot = transitionContainer.window!.snapshotView(afterScreenUpdates: true)!
    transitionContainer.window!.addSubview(fullScreenSnapshot)

    if let oldSnapshots = fromViewController?.hero_storedSnapshots {
      for snapshot in oldSnapshots {
        snapshot.removeFromSuperview()
      }
      fromViewController?.hero_storedSnapshots = nil
    }
    if let oldSnapshots = toViewController?.hero_storedSnapshots {
      for snapshot in oldSnapshots {
        snapshot.removeFromSuperview()
      }
      toViewController?.hero_storedSnapshots = nil
    }

    prepareForTransition()

    context.loadViewAlpha(rootView: toView)
    context.loadViewAlpha(rootView: fromView)
    context.hide(view: toView)
    container.addSubview(toView)
    container.addSubview(fromView)

    toView.frame = fromView.frame
    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()

    context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)

    if !skipDefaultAnimation {
      if !(fromOverFullScreen && !presenting) {
        context[toView] = [.fade, .durationMatchLongest]
      }

      if (!presenting && toOverFullScreen) || !fromView.isOpaque || (fromView.backgroundColor?.alphaComponent ?? 1) < 1 {
        context[fromView] = [.fade, .durationMatchLongest]
      }

      if toView.layer.zPosition < fromView.layer.zPosition {
        // in this case, we have to animate the zPosition as well. otherwise the fade animation will be hidden.

        if context[toView] == nil {
          context[toView] = []
        }
        context[toView]!.append(contentsOf: [.zPosition(toView.layer.zPosition - 1), .durationMatchLongest])

        if context[fromView] == nil {
          context[fromView] = []
        }
        context[fromView]!.append(contentsOf: [.zPosition(toView.layer.zPosition - 1), .durationMatchLongest])
      }
    }

    prepareForAnimation()

    #if os(tvOS)
      animate()
    #else
      if inContainerController {
        // When animating within navigationController, we have to dispatch later in the runloop. 
        // otherwise snapshots will not be taken. Possibly a bug with UIKit
        DispatchQueue.main.async {
          self.animate()
        }
      } else {
        animate()
      }
    #endif
  }

  override func animate() {
    context.unhide(view: toView)
    if let containerColor = containerColor {
      container.backgroundColor = containerColor
    } else if !toOverFullScreen && !fromOverFullScreen {
      container.backgroundColor = toView.backgroundColor
    }

    super.animate()

    fullScreenSnapshot!.removeFromSuperview()
  }

  override func complete(finished: Bool) {
    guard transitioning else { return }

    if finished && presenting && toOverFullScreen {
      // finished presenting a overFullScreen VC
      context.unhide(rootView: toView)
      context.removeSnapshots(rootView: toView)
      context.storeViewAlpha(rootView: fromView)
      fromViewController!.hero_storedSnapshots = context.snapshots(rootView: fromView)
    } else if !finished && !presenting && fromOverFullScreen {
      // cancelled dismissing a overFullScreen VC
      context.unhide(rootView: fromView)
      context.removeSnapshots(rootView: fromView)
      context.storeViewAlpha(rootView: toView)
      toViewController!.hero_storedSnapshots = context.snapshots(rootView: toView)
    } else {
      context.unhideAll()
      context.removeAllSnapshots()
    }

    // move fromView & toView back from our container back to the one supplied by UIKit
    transitionContainer.addSubview(finished ? fromView : toView)
    transitionContainer.addSubview(finished ? toView : fromView)

    if presenting != finished, !inContainerController {
      // only happens when present a .overFullScreen VC
      // bug: http://openradar.appspot.com/radar?id=5320103646199808
      UIApplication.shared.keyWindow!.addSubview(presenting ? fromView : toView)
    }
    
    // use temp variables to remember these values
    // because we have to reset everything before calling
    // any delegate or completion block
    let tContext = transitionContext
    let fvc = fromViewController
    let tvc = toViewController

    transitionContext = nil
    fromViewController = nil
    toViewController = nil
    containerColor = nil
    inNavigationController = false
    inTabBarController = false
    forceNotInteractive = false
    skipDefaultAnimation = false

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
  }
}

// custom transition helper, used in hero_replaceViewController
internal extension Hero {
  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
    guard !transitioning else { return }
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
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
    let fromVCIndex = tabBarController.childViewControllers.index(of: fromVC)!
    let toVCIndex = tabBarController.childViewControllers.index(of: toVC)!
    self.presenting = toVCIndex > fromVCIndex
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inTabBarController = true
    return self
  }
}
