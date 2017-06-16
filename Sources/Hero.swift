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

public enum HeroState: Int {
  // Hero is able to start a new transition
  case possible

  // UIKit has notified Hero about a pending transition.
  // Hero haven't started preparing.
  case notified

  // Hero's `start` method has been called. Preparing the animation.
  case starting

  // Hero's `animate` method has been called. Animation has started.
  case animating

  // Hero's `complete` method has been called. Transition is ended or cancelled. Hero is doing cleanup.
  case completing
}


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
public class Hero: NSObject {
  // MARK: Shared Access

  /// Shared singleton object for controlling the transition
  public static let shared = Hero()

  public internal(set) var state: HeroState = .possible {
    didSet {
      print("Hero state \(state)")
    }
  }


  public var transitioning: Bool {
    return isTransitioning
  }
  public var isTransitioning: Bool {
    return state != .possible
  }
  public var presenting: Bool {
    return isPresenting
  }
  public internal(set) var isPresenting: Bool = true

  /// container we created to hold all animating views, will be a subview of the
  /// transitionContainer when transitioning
  public internal(set) var container: UIView!

  /// this is the container supplied by UIKit
  internal var transitionContainer: UIView!

  internal var completionCallback: ((Bool) -> Void)?

  internal var processors: [HeroPreprocessor]!
  internal var animators: [HeroAnimator]!
  internal var plugins: [HeroPlugin]!
  internal var animatingFromViews: [UIView]!
  internal var animatingToViews: [UIView]!
  internal static var enabledPlugins: [HeroPlugin.Type] = []

  /// destination view controller
  public internal(set) var toViewController: UIViewController?
  /// source view controller
  public internal(set) var fromViewController: UIViewController?

  /// context object holding transition informations
  public internal(set) var context: HeroContext!

  /// whether or not we are handling transition interactively
  public var interactive: Bool {
    return displayLink == nil
  }

  internal var displayLink: CADisplayLink?
  internal var progressUpdateObservers: [HeroProgressUpdateObserver]?

  /// max duration needed by the default animator and plugins
  public internal(set) var totalDuration: TimeInterval = 0.0

  /// current animation complete duration.
  /// (differs from totalDuration because this one could be the duration for finishing interactive transition)
  internal var currentDuration: TimeInterval = 0.0
  internal var finishing: Bool = true
  internal var beginTime: TimeInterval? {
    didSet {
      if beginTime != nil {
        if displayLink == nil {
          displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
          displayLink!.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        }
      } else {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        displayLink = nil
      }
    }
  }

  @objc func displayUpdate(_ link: CADisplayLink) {
    if transitioning, currentDuration > 0, let beginTime = beginTime {
      let timePassed = CACurrentMediaTime() - beginTime

      if timePassed > currentDuration {
        progress = finishing ? 1 : 0
        self.beginTime = nil
        complete(finished: finishing)
      } else {
        var completed = timePassed / totalDuration
        if !finishing {
          completed = 1 - completed
        }
        completed = max(0, min(1, completed))
        progress = completed
      }
    }
  }

  /// progress of the current transition. 0 if no transition is happening
  public internal(set) var progress: Double = 0 {
    didSet {
      if state == .animating {
        if let progressUpdateObservers = progressUpdateObservers {
          for observer in progressUpdateObservers {
            observer.heroDidUpdateProgress(progress: progress)
          }
        }

        let timePassed = progress * totalDuration
        if interactive {
          for animator in animators {
            animator.seekTo(timePassed: timePassed)
          }
        } else {
          for plugin in plugins where plugin.requirePerFrameCallback {
            plugin.seekTo(timePassed: timePassed)
          }
        }

        transitionContext?.updateInteractiveTransition(CGFloat(progress))
      }
    }
  }

  /// a UIViewControllerContextTransitioning object provided by UIKit,
  /// might be nil when transitioning. This happens when calling heroReplaceViewController
  internal weak var transitionContext: UIViewControllerContextTransitioning?

  internal var fullScreenSnapshot: UIView!

  internal var defaultAnimation: HeroDefaultAnimationType = .auto
  internal var containerColor: UIColor?

  // By default, Hero will always appear to be interactive to UIKit. This forces it to appear non-interactive.
  // Used when doing a hero_replaceViewController within a UINavigationController, to fix a bug with
  // UINavigationController.setViewControllers not able to handle interactive transition
  internal var forceNotInteractive = false

  internal var inNavigationController = false
  internal var inTabBarController = false
  internal var inContainerController: Bool {
    return inNavigationController || inTabBarController
  }
  internal var toOverFullScreen: Bool {
    return !inContainerController && (toViewController!.modalPresentationStyle == .overFullScreen || toViewController!.modalPresentationStyle == .overCurrentContext)
  }
  internal var fromOverFullScreen: Bool {
    return !inContainerController && (fromViewController!.modalPresentationStyle == .overFullScreen || fromViewController!.modalPresentationStyle == .overCurrentContext)
  }

  internal var toView: UIView { return toViewController!.view }
  internal var fromView: UIView { return fromViewController!.view }

  internal override init() { super.init() }

  /// Turn off built-in animation for next transition
  public func disableDefaultAnimationForNextTransition() {
    defaultAnimation = .none
  }

  /// Set the default animation for next transition
  /// This usually overrides rootView's heroModifiers during the transition
  ///
  /// - Parameter animation: animation type
  public func setDefaultAnimationForNextTransition(_ animation: HeroDefaultAnimationType) {
    defaultAnimation = animation
  }

  /// Set the container color for next transition
  ///
  /// - Parameter color: container color
  public func setContainerColorForNextTransition(_ color: UIColor?) {
    containerColor = color
  }

  func start() {
    guard state == .notified else { return }
    state = .starting

    toView.frame = fromView.frame
    toView.setNeedsLayout()
    toView.layoutIfNeeded()

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
    fullScreenSnapshot = transitionContainer.window?.snapshotView(afterScreenUpdates: true) ?? fromView.snapshotView(afterScreenUpdates: true)
    (transitionContainer.window ?? transitionContainer)?.addSubview(fullScreenSnapshot)

    if let oldSnapshot = fromViewController?.heroStoredSnapshot {
      oldSnapshot.removeFromSuperview()
      fromViewController?.heroStoredSnapshot = nil
    }
    if let oldSnapshot = toViewController?.heroStoredSnapshot {
      oldSnapshot.removeFromSuperview()
      toViewController?.heroStoredSnapshot = nil
    }

    plugins = Hero.enabledPlugins.map({ return $0.init() })
    processors = [
      IgnoreSubviewModifiersPreprocessor(),
      MatchPreprocessor(),
      SourcePreprocessor(),
      CascadePreprocessor(),
      DefaultAnimationPreprocessor(hero: self),
      DurationPreprocessor()
    ]
    animators = [
      HeroDefaultAnimator<HeroCoreAnimationViewContext>()
    ]

    if #available(iOS 10, tvOS 10, *) {
      animators.append(HeroDefaultAnimator<HeroViewPropertyViewContext>())
    }

    // There is no covariant in Swift, so we need to add plugins one by one.
    for plugin in plugins {
      processors.append(plugin)
      animators.append(plugin)
    }

    transitionContainer.isUserInteractionEnabled = false

    // a view to hold all the animating views
    container = UIView(frame: transitionContainer.bounds)
    transitionContainer.addSubview(container)

    context = HeroContext(container:container)

    for processor in processors {
      processor.context = context
    }
    for animator in animators {
      animator.context = context
    }

    context.loadViewAlpha(rootView: toView)
    context.loadViewAlpha(rootView: fromView)
    container.addSubview(toView)
    container.addSubview(fromView)

    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()

    context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)

    if !presenting && !inTabBarController {
      context.insertToViewFirst = true
    }

    for processor in processors {
      processor.process(fromViews: context.fromViews, toViews: context.toViews)
    }
    animatingFromViews = context.fromViews.filter { (view: UIView) -> Bool in
      for animator in animators {
        if animator.canAnimate(view: view, appearing: false) {
          return true
        }
      }
      return false
    }
    animatingToViews = context.toViews.filter { (view: UIView) -> Bool in
      for animator in animators {
        if animator.canAnimate(view: view, appearing: true) {
          return true
        }
      }
      return false
    }

    context.hide(view: toView)

    #if os(tvOS)
      animate()
    #else
      if inNavigationController {
        // When animating within navigationController, we have to dispatch later into the main queue.
        // otherwise snapshots will be pure white. Possibly a bug with UIKit
        DispatchQueue.main.async {
          self.animate()
        }
      } else {
        animate()
      }
    #endif
  }

  func complete(after: TimeInterval, finishing: Bool) {
    guard transitioning else { fatalError() }
    if after <= 0.001 {
      complete(finished: finishing)
      return
    }
    let timePassed = (finishing ? progress : 1 - progress) * totalDuration
    self.finishing = finishing
    self.currentDuration = after + timePassed
    self.beginTime = CACurrentMediaTime() - timePassed
  }

  func complete(finished: Bool) {
    guard [HeroState.animating, .starting, .notified].contains(state) else { fatalError() }
    state = .completing

    context.clean()

    if finished && presenting && toOverFullScreen {
      // finished presenting a overFullScreen VC
      context.unhide(rootView: toView)
      context.removeSnapshots(rootView: toView)
      context.storeViewAlpha(rootView: fromView)
      fromViewController!.heroStoredSnapshot = container
      container.superview!.addSubview(fromView)
      fromView.addSubview(container)
    } else if !finished && !presenting && fromOverFullScreen {
      // cancelled dismissing a overFullScreen VC
      context.unhide(rootView: fromView)
      context.removeSnapshots(rootView: fromView)
      context.storeViewAlpha(rootView: toView)
      toViewController!.heroStoredSnapshot = container
      container.superview!.addSubview(toView)
      toView.addSubview(container)
    } else {
      context.unhideAll()
      context.removeAllSnapshots()
    }

    // move fromView & toView back from our container back to the one supplied by UIKit
    if (toOverFullScreen && finished) || (fromOverFullScreen && !finished) {
      transitionContainer.addSubview(finished ? fromView : toView)
    }
    transitionContainer.addSubview(finished ? toView : fromView)

    if presenting != finished, !inContainerController {
      // only happens when present a .overFullScreen VC
      // bug: http://openradar.appspot.com/radar?id=5320103646199808
      UIApplication.shared.keyWindow?.addSubview(presenting ? fromView : toView)
    }

    if container.superview == transitionContainer {
      container.removeFromSuperview()
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
    defaultAnimation = .auto

    for animator in animators {
      animator.clean()
    }

    transitionContainer!.isUserInteractionEnabled = true

    let completion = completionCallback

    animatingToViews = nil
    animatingFromViews = nil
    progressUpdateObservers = nil
    transitionContainer = nil
    completionCallback = nil
    container = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    beginTime = nil
    progress = 0
    totalDuration = 0

    completion?(finished)

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

  /// Actually animate the views
  /// subclass should call `prepareForTransition` & `prepareForAnimation` before calling `animate`
  open func animate() {
    guard state == .starting else { fatalError() }
    state = .animating

    context.unhide(view: toView)

    if let containerColor = containerColor {
      container.backgroundColor = containerColor
    } else if !toOverFullScreen && !fromOverFullScreen {
      container.backgroundColor = toView.backgroundColor
    }

    // auto hide all animated views
    for view in animatingFromViews {
      context.hide(view: view)
    }
    for view in animatingToViews {
      context.hide(view: view)
    }

    var totalDuration: TimeInterval = 0
    var animatorWantsInteractive = false

    if context.insertToViewFirst {
      for v in animatingToViews { _ = context.snapshotView(for: v) }
      for v in animatingFromViews { _ = context.snapshotView(for: v) }
    } else {
      for v in animatingFromViews { _ = context.snapshotView(for: v) }
      for v in animatingToViews { _ = context.snapshotView(for: v) }
    }

    for animator in animators {
      let duration = animator.animate(fromViews: animatingFromViews.filter({ animator.canAnimate(view: $0, appearing: false) }),
                                      toViews: animatingToViews.filter({ animator.canAnimate(view: $0, appearing: true) }))
      if duration == .infinity {
        animatorWantsInteractive = true
      } else {
        totalDuration = max(totalDuration, duration)
      }
    }

    self.totalDuration = totalDuration
    if animatorWantsInteractive {
      update(0)
    } else {
      complete(after: totalDuration, finishing: true)
    }

    fullScreenSnapshot!.removeFromSuperview()
  }
}

// custom transition helper, used in hero_replaceViewController
internal extension Hero {
  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
    guard !isTransitioning else { return }
    self.state = .notified
    isPresenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = {
      completion?($0)
      self.state = .possible
    }
    start()
  }
}

// delegate helper
internal extension Hero {
  func closureProcessForHeroDelegate<T: UIViewController>(vc: T, closure: (HeroViewControllerDelegate) -> Void) {
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
    transitionContext = context
    fromViewController = fromViewController ?? context.viewController(forKey: .from)
    toViewController = toViewController ?? context.viewController(forKey: .to)
    transitionContainer = context.containerView
    start()
  }
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.375 // doesn't matter, real duration will be calculated later
  }

  public func animationEnded(_ transitionCompleted: Bool) {
    self.state = .possible
  }
}

extension Hero:UIViewControllerTransitioningDelegate {
  var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
    return forceNotInteractive ? nil : self
  }

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard !isTransitioning else { return nil }
    self.state = .notified
    self.isPresenting = true
    self.fromViewController = fromViewController ?? presenting
    self.toViewController = toViewController ?? presented
    return self
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard !isTransitioning else { return nil }
    self.state = .notified
    self.isPresenting = false
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
    guard !isTransitioning else { return nil }
    self.state = .notified
    self.isPresenting = operation == .push
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
  public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    return !isTransitioning
  }

  public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }

  public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    guard !isTransitioning else { return nil }
    self.state = .notified
    let fromVCIndex = tabBarController.childViewControllers.index(of: fromVC)!
    let toVCIndex = tabBarController.childViewControllers.index(of: toVC)!
    self.isPresenting = toVCIndex > fromVCIndex
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inTabBarController = true
    return self
  }
}
