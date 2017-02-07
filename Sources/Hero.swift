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
public class Hero: NSObject {
  // MARK: Shared Access

  /// Shared singleton object for controlling the transition
  public static let shared = Hero()
  
  // MARK: Properties

  /// destination view controller
  public internal(set) var toViewController: UIViewController?
  /// source view controller
  public internal(set) var fromViewController: UIViewController?
  /// context object holding transition informations
  public fileprivate(set) var context: HeroContext!
  /// whether or not we are presenting the destination view controller
  public fileprivate(set) var presenting = true
  /// whether or not we are handling transition interactively
  public var interactive: Bool {
    return displayLink == nil
  }
  /// progress of the current transition. 0 if no transition is happening
  public fileprivate(set) var progress: Double = 0 {
    didSet {
      if transitioning {
        transitionContext?.updateInteractiveTransition(CGFloat(progress))
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
          for plugin in plugins {
            if plugin.requirePerFrameCallback {
              plugin.seekTo(timePassed: timePassed)
            }
          }
        }
      }
    }
  }
  /// whether or not we are doing a transition
  public var transitioning: Bool {
    return transitionContainer != nil
  }
  
  /// container we created to hold all animating views, will be a subview of the
  /// transitionContainer when transitioning
  public fileprivate(set) var container: UIView!
  
  /// this is the container supplied by UIKit
  fileprivate var transitionContainer: UIView!
  
  /// a UIViewControllerContextTransitioning object provided by UIKit,
  /// might be nil when transitioning. This happens when calling heroReplaceViewController
  fileprivate weak var transitionContext: UIViewControllerContextTransitioning?

  internal var completionCallback: ((Bool) -> Void)?
  
  // By default, Hero will always appear to be interactive to UIKit. This forces it to appear non-interactive.
  // Used when doing a hero_replaceViewController within a UINavigationController, to fix a bug with 
  // UINavigationController.setViewControllers not able to handle interactive transition
  internal var forceNotInteractive = false
  
  
  fileprivate var displayLink: CADisplayLink?
  fileprivate var progressUpdateObservers: [HeroProgressUpdateObserver]?
  
  /// max duration needed by the default animator and plugins
  public fileprivate(set) var totalDuration: TimeInterval = 0.0
  fileprivate var duration: TimeInterval = 0.0
  fileprivate var beginTime: TimeInterval? {
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
  func displayUpdate(_ link: CADisplayLink) {
    if transitioning, duration > 0, let beginTime = beginTime {
      let timePassed = CACurrentMediaTime() - beginTime
      
      if timePassed > duration {
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
  
  
  fileprivate var finishing: Bool = true
  /// true if transitioning inside a UINavigationController or UITabBarController
  fileprivate var inContainerController = false
  
  fileprivate var toView: UIView { return toViewController!.view }
  fileprivate var fromView: UIView { return fromViewController!.view }
  
  fileprivate var processors: [HeroPreprocessor]!
  fileprivate var animators: [HeroAnimator]!
  fileprivate var plugins: [HeroPlugin]!
  
  fileprivate static var enabledPlugins: [HeroPlugin.Type] = []
  
  fileprivate override init() {}
}

public extension Hero {
  // MARK: Interactive Transition
  
  /**
   Update the progress for the interactive transition.
   - Parameters:
       - progress: the current progress, must be between 0...1
   */
  public func update(progress: Double) {
    guard transitioning else { return }
    let progress = max(0, min(1, progress))
    beginTime = nil
    self.progress = progress
  }
  
  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func end(animate: Bool = true) {
    guard transitioning && interactive else { return }
    if !animate {
      complete(finished:true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:progress * totalDuration, reverse: false))
    }
    complete(after: maxTime, finishing: true)
  }
  
  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the 
   current state to the **begining** state
   */
  public func cancel(animate: Bool = true) {
    guard transitioning && interactive else { return }
    if !animate {
      complete(finished:false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:progress * totalDuration, reverse: true))
    }
    complete(after: maxTime, finishing: false)
  }
  
  /**
   Override modifiers during an interactive animation.
   
   For example:
   
       Hero.shared.apply([.position(x:50, y:50)], to:view)
   
   will set the view's position to 50, 50
   - Parameters:
       - modifiers: the modifiers to override
       - view: the view to override to
   */
  public func apply(modifiers: [HeroModifier], to view: UIView) {
    guard transitioning && interactive else { return }
    let targetState = HeroTargetState(modifiers: modifiers)
    if let otherView = context.pairedView(for: view) {
      for animator in animators {
        animator.apply(state: targetState, to: otherView)
      }
    }
    for animator in animators {
      animator.apply(state: targetState, to: view)
    }
  }
}

public extension Hero {
  // MARK: Observe Progress

  /**
   Receive callbacks on each animation frame.
   Observers will be cleaned when transition completes
   
   - Parameters:
     - observer: the observer
   */
  func observeForProgressUpdate(observer: HeroProgressUpdateObserver) {
    if progressUpdateObservers == nil {
      progressUpdateObservers = []
    }
    progressUpdateObservers!.append(observer)
  }
}

// internal methods for transition
internal extension Hero {
  func start() {
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

    plugins = Hero.enabledPlugins.map({ return $0.init() })
    processors = [
      IgnoreSubviewModifiersPreprocessor(),
      MatchPreprocessor(),
      SourcePreprocessor(),
      CascadePreprocessor()
    ]
    animators = [
      HeroDefaultAnimator()
    ]
    
    // There is no covariant in Swift, so we need to add plugins one by one.
    for plugin in plugins {
      processors.append(plugin)
      animators.append(plugin)
    }
    
    transitionContainer.isUserInteractionEnabled = false
    
    // a view to hold all the animating views
    container = UIView(frame: transitionContainer.bounds)
    transitionContainer.addSubview(container)
    
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

    context.set(fromView: fromView, toView: toView)

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

      if toView.layer.zPosition < fromView.layer.zPosition {
        // in this case, we have to animate the zPosition as well. otherwise the fade animation will be hidden.
        context[toView]!.append(.zPosition(fromView.layer.zPosition + 1))
        context[fromView] = [.zPosition(toView.layer.zPosition - 1)]
        animatingViews[0].0.insert(fromView, at: 0)
      }
    }
    
    // wait for a frame if using navigation controller.
    // a bug with navigation controller. the snapshot is not captured if animating immediately
    delay(inContainerController && presenting ? 0.02 : 0) {
      self.context.unhide(view: self.toView)
      self.container.backgroundColor = self.toView.backgroundColor
      for (currentFromViews, currentToViews) in animatingViews {
        // auto hide all animated views
        for view in currentFromViews {
          self.context.hide(view: view)
        }
        for view in currentToViews {
          self.context.hide(view: view)
        }
      }
      
      var totalDuration: TimeInterval = 0
      var animatorWantsInteractive = false
      for (i, animator) in self.animators.enumerated() {
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
        self.animators.first?.apply(state: [.duration(totalDuration)], to: self.toView)
      }

      // we are done with setting up, so remove the covering snapshot
      completeSnapshot.removeFromSuperview()
      self.totalDuration = totalDuration
      if animatorWantsInteractive {
        self.update(progress: 0.001)
      } else {
        self.complete(after: totalDuration, finishing: true)
      }
    }
  }
  
  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: ((Bool) -> Void)? = nil) {
    guard !transitioning else { return }
    inContainerController = false
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
  }
  
  func complete(after: TimeInterval, finishing: Bool) {
    if after <= 0.001 {
      complete(finished: finishing)
      return
    }
    let timePassed = (finishing ? progress : 1 - progress) * totalDuration
    self.finishing = finishing
    self.duration = after + timePassed
    self.beginTime = CACurrentMediaTime() - timePassed
  }

  func complete(finished: Bool) {
    guard transitioning else { return }
    for animator in animators {
      animator.clean()
    }
    context.unhideAll()

    // move fromView & toView back from animatingViewContainer
    transitionContainer.addSubview(finished ? toView : fromView)
    
    container.removeFromSuperview()
    transitionContainer!.isUserInteractionEnabled = true
    
    // use temp variables to remember these values
    // because we have to reset everything before calling
    // any delegate or completion block
    let tContext = transitionContext
    let completion = completionCallback
    let fvc = fromViewController
    let tvc = toViewController
    
    progressUpdateObservers = nil
    transitionContainer = nil
    transitionContext = nil
    fromViewController = nil
    toViewController = nil
    completionCallback = nil
    container = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    beginTime = nil
    inContainerController = false
    forceNotInteractive = false
    progress = 0
    totalDuration = 0

    
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

// MARK: Plugin Support
internal extension Hero {
  static func isEnabled(plugin: HeroPlugin.Type) -> Bool {
    return enabledPlugins.index(where: { return $0 == plugin}) != nil
  }
  
  static func enable(plugin: HeroPlugin.Type) {
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }
  
  static func disable(plugin: HeroPlugin.Type) {
    if let index = enabledPlugins.index(where: { return $0 == plugin}) {
      enabledPlugins.remove(at: index)
    }
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
    self.inContainerController = true
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
    self.inContainerController = true
    return self
  }
}
