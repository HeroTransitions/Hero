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

public class Hero:NSObject {
  /**
   ## The Singleton object for controlling interactive transitions.
   
       var presenting:Bool
       var interactive:Bool
   
   ### Use the following methods for controlling the interactive transition:
       func update(progress:Double)
       func end()
       func cancel()
       func apply(modifiers:[HeroModifier], to view:UIView)
   */
  public static let shared = Hero()
  
  public fileprivate(set) weak var toViewController:UIViewController?
  public fileprivate(set) weak var fromViewController:UIViewController?
  public fileprivate(set) var interactive = false
  public fileprivate(set) var presenting = true
  public var transitioning:Bool{
    return transitionContainer != nil
  }
  
  // container we created to hold all animating views, will be a subview of the 
  // transitionContainer when transitioning
  public fileprivate(set) var container: UIView!
  
  // this is the container supplied by UIKit
  fileprivate var transitionContainer:UIView!
  
  // a UIViewControllerContextTransitioning object provided by UIKit,
  // might be nil when transitioning. This happens when calling heroReplaceViewController
  fileprivate weak var transitionContext: UIViewControllerContextTransitioning?
  
  fileprivate var completionCallback: (() -> Void)?
  
  // max duration needed by the default animator and plugins
  fileprivate var maxDurationNeeded: TimeInterval = 0.0
  
  // true if transitioning inside a UINavigationController or UITabBarController
  fileprivate var inContainerController = false
  
  fileprivate var toView: UIView { return toViewController!.view }
  fileprivate var fromView: UIView { return fromViewController!.view }
  
  fileprivate var context: HeroContext!
  
  fileprivate var processors: [HeroPreprocessor]!
  fileprivate var animators: [HeroAnimator]!
  fileprivate var plugins: [HeroPlugin]!
  
  fileprivate static var enabledPlugins: [HeroPlugin.Type] = []
  fileprivate var lastProgress:Double = 0
  
  fileprivate override init(){}
}

public extension Hero {
  /**
   Update the progress for the interactive transition.
   - Parameters:
       - progress: the current progress, must be between 0...1
   */
  public func update(progress: Double) {
    let p = max(0, min(1, progress))
    lastProgress = p
    guard transitioning && interactive else { return }
    for animator in animators {
      animator.seekTo(timePassed: p * maxDurationNeeded)
    }
    transitionContext?.updateInteractiveTransition(CGFloat(p))
  }
  
  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func end() {
    guard transitioning && interactive else { return }
    var maxTime:TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:lastProgress*maxDurationNeeded, reverse: false))
    }
    transitionContext?.finishInteractiveTransition()
    delay(maxTime) {
      self.end(finished: true)
    }
  }
  
  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the 
   current state to the **begining** state
   */
  public func cancel() {
    guard transitioning && interactive else { return }
    var maxTime:TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:lastProgress*maxDurationNeeded, reverse: true))
    }
    transitionContext?.cancelInteractiveTransition()
    delay(maxTime){
      self.end(finished: false)
    }
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
  public func apply(modifiers:[HeroModifier], to view:UIView) {
    guard transitioning && interactive else { return }
    let targetState = HeroTargetState(modifiers: modifiers)
    if let otherView = context.pairedView(for: view){
      for animator in animators {
        animator.apply(state: targetState, to: otherView)
      }
    }
    for animator in animators {
      animator.apply(state: targetState, to: view)
    }
  }
}

// methods for transition
internal extension Hero {
  func start() {
    if plugins == nil {
      // need this check because plugins might be initialized
      // when UIKit ask if hero wants interactive transition
      plugins = Hero.enabledPlugins.map({ return $0.init() })
    }
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
    
    transitionContainer.isUserInteractionEnabled = false
    
    // a view to hold all the animating views
    container = UIView(frame: transitionContainer.bounds)
    transitionContainer.addSubview(container)
    
    // take a snapshot to hide all the flashing that might happen
    let completeSnapshot = fromView.snapshotView(afterScreenUpdates: true)!
    transitionContainer.addSubview(completeSnapshot)
    
    // need to add fromView first, then insert toView under it. This eliminates the flash
    container.addSubview(fromView)
    container.insertSubview(toView, belowSubview: fromView)
    container.backgroundColor = toView.backgroundColor
    
    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()
    
    context = HeroContext(container:container, fromView: fromView, toView:toView)
    
    // ask each preprocessor to process
    
    for processor in processors {
      processor.process(context:context, fromViews: context.fromViews, toViews: context.toViews)
    }
    
    var skipDefaultAnimation = false
    var animatingViews = [([UIView],[UIView])]()
    for animator in animators {
      let currentFromViews = context.fromViews.filter{ [context] (view:UIView) -> Bool in
        return animator.canAnimate(context: context!, view: view, appearing: false)
      }
      let currentToViews = context.toViews.filter{ [context] (view:UIView) -> Bool in
        return animator.canAnimate(context: context!, view: view, appearing: true)
      }
      if currentFromViews.first == fromView || currentToViews.first == toView{
        skipDefaultAnimation = true
      }
      animatingViews.append((currentFromViews, currentToViews))
    }
    
    if !skipDefaultAnimation {
      // if no animator can animate toView & fromView, set the effect to fade // i.e. default effect
      context[toView] = [.fade]
      animatingViews[0].1.insert(toView, at: 0)
    }
    
    // wait for a frame if using navigation controller.
    // a bug with navigation controller. the snapshot is not captured if animating immediately
    delay(inContainerController && presenting ? 0.02 : 0) {
      for (currentFromViews, currentToViews) in animatingViews {
        // auto hide all animated views
        for view in currentFromViews {
          self.context.hide(view: view)
        }
        for view in currentToViews {
          self.context.hide(view: view)
        }
      }
      
      for (i, animator) in self.animators.enumerated() {
        let duration = animator.animate(context: self.context,
                                        fromViews: animatingViews[i].0,
                                        toViews: animatingViews[i].1)
        self.maxDurationNeeded = max(self.maxDurationNeeded, duration)
      }
      
      // we are done with setting up, so remove the covering snapshot
      completeSnapshot.removeFromSuperview()
      
      if self.interactive {
        if self.lastProgress == 0 {
          self.update(progress: 0)
        }
      } else {
        delay(self.maxDurationNeeded) {
          self.end(finished: true)
        }
      }
    }
  }
  
  func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: (() -> Void)? = nil) {
    guard !transitioning else { return }
    inContainerController = false
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
  }
  
  func end(finished: Bool) {
    guard transitioning else { return }
    for animator in animators{
      animator.clean()
    }
    context.unhideAll()
    
    // move fromView & toView back from animatingViewContainer
    transitionContainer.addSubview(finished ? toView : fromView)
    
    if presenting != finished, !inContainerController {
      // bug: http://openradar.appspot.com/radar?id=5320103646199808
      UIApplication.shared.keyWindow!.addSubview(toView)
    }
    
    container.removeFromSuperview()
    container = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    inContainerController = false
    interactive = false
    lastProgress = 0
    maxDurationNeeded = 0
    
    transitionContainer!.isUserInteractionEnabled = true
    
    // use temp variables to remember these values
    // because we have to reset everything before calling 
    // any delegate or completion block
    let tContext = transitionContext
    let completion = completionCallback
    let fvc = fromViewController
    let tvc = fromViewController
    
    transitionContainer = nil
    transitionContext = nil
    fromViewController = nil
    toViewController = nil
    completionCallback = nil
    
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

    tContext?.completeTransition(finished)
    completion?()
  }
}

// plugin support
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
  }
}

















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
    return 0.375
  }
}

extension Hero:UIViewControllerTransitioningDelegate {
  fileprivate var interactiveTransitioning: UIViewControllerInteractiveTransitioning? {
    closureProcessForHeroDelegate(vc: fromViewController!) {
      interactive = $0.wantInteractiveHeroTransition?() ?? false
    }
    
    if !interactive {
      Hero.enabledPlugins.map { $0.init() }.forEach {
        if $0.wantInteractiveHeroTransition() {
          interactive = true
          return
        }
      }
    }
    
    return interactive ? self : nil
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
