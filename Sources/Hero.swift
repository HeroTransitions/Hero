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
  public static var shared = Hero()
  
  public weak var toViewController:UIViewController?
  public weak var fromViewController:UIViewController?
  
  var interactive = false

  public var container: UIView! {
    return animatingViewContainer
  }
  public var transitioning:Bool{
    return transitionContainer != nil
  }
  var transitionContainer:UIView!
  public fileprivate(set) var presenting = true
  fileprivate var completionCallback: (() -> Void)?
  
  fileprivate var maxDurationNeeded: TimeInterval = 0.0
  fileprivate var inContainerController = false
  fileprivate weak var transitionContext: UIViewControllerContextTransitioning?
  
  fileprivate var toView: UIView { return toViewController!.view }
  fileprivate var fromView: UIView { return fromViewController!.view }
  
  fileprivate var context: HeroContext!
  fileprivate var animatingViewContainer: UIView!
  
  fileprivate var processors: [HeroPreprocessor]!
  fileprivate var animators: [HeroAnimator]!
  fileprivate var plugins: [HeroPlugin]!
  
  fileprivate static let builtInProcessors: [HeroPreprocessor] = [
    IgnoreSubviewModifiersPreprocessor(),
    MatchPreprocessor(),
    SourcePreprocessor(),
    CascadePreprocessor()
  ]

  fileprivate static let builtInAnimator = [
    HeroDefaultAnimator()
  ]
  
  fileprivate static var enabledPlugins: [HeroPlugin.Type] = []
  var lastProgress:Double = 0
  
  fileprivate override init(){}
}

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

internal extension Hero {
  func start() {
    if plugins == nil {
      plugins = Hero.enabledPlugins.map({ return $0.init() })
    }
    processors = Hero.builtInProcessors
    animators = Hero.builtInAnimator
    
    // swift 3 bug. no idea why it wont let me to use append(contentsOf:) or + operator
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
    
    // a view to hold all the animation views
    animatingViewContainer = UIView(frame: transitionContainer.bounds)
    transitionContainer.addSubview(animatingViewContainer)
    
    // create a snapshot view to hide all the flashing that might happen
    let completeSnapshot = fromView.snapshotView(afterScreenUpdates: true)!
    transitionContainer.addSubview(completeSnapshot)
    
    animatingViewContainer.addSubview(fromView)
    animatingViewContainer.insertSubview(toView, belowSubview: fromView)
    animatingViewContainer.backgroundColor = toView.backgroundColor

    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()
    
    context = HeroContext(container:animatingViewContainer, fromView: fromView, toView:toView)
    
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

  internal func transition(from: UIViewController, to: UIViewController, in view: UIView, completion: (() -> Void)? = nil) {
    guard !transitioning else { return }
    inContainerController = false
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
  }
  
  internal func end(finished: Bool) {
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

    animatingViewContainer.removeFromSuperview()
    animatingViewContainer = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    inContainerController = false
    interactive = false
    lastProgress = 0
    maxDurationNeeded = 0
    
    transitionContainer!.isUserInteractionEnabled = true
    let transitionContext = self.transitionContext
    let completion = completionCallback
    
    transitionContext?.completeTransition(finished)
    completion?()
    
    if let fvc = fromViewController, let tvc = toViewController {
        closureProcessForHeroDelegate(vc: fvc) {
            $0.heroDidEndAnimatingTo?(viewController: tvc)
            $0.heroDidEndTransition?()
        }
        
        closureProcessForHeroDelegate(vc: tvc) {
            $0.heroDidEndAnimatingFrom?(viewController: fvc)
            $0.heroDidEndTransition?()
        }
    }

    transitionContainer = nil
    self.transitionContext = nil
    fromViewController = nil
    toViewController = nil
    completionCallback = nil
  }
}

public extension Hero {
  public func update(progress: Double) {
    let p = max(0, min(1, progress))
    lastProgress = p
    guard transitioning else { return }
    for animator in animators {
      animator.seekTo(timePassed: p * maxDurationNeeded)
    }
    transitionContext?.updateInteractiveTransition(CGFloat(p))
  }

  public func end() {
    guard transitioning else { return }
    var maxTime:TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:lastProgress*maxDurationNeeded, reverse: false))
    }
    transitionContext?.finishInteractiveTransition()
    delay(maxTime) {
      self.end(finished: true)
    }
  }

  public func cancel() {
    guard transitioning else { return }
    var maxTime:TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:lastProgress*maxDurationNeeded, reverse: true))
    }
    transitionContext?.cancelInteractiveTransition()
    delay(maxTime){
      self.end(finished: false)
    }
  }

  public func temporarilySet(view:UIView, modifiers:[HeroModifier]){
    guard transitioning else { return }
    let targetState = HeroTargetState(modifiers: modifiers)
    if let otherView = context.pairedView(for: view){
      for animator in animators {
        animator.temporarilySet(view: otherView, targetState: targetState)
      }
    }
    for animator in animators {
        animator.temporarilySet(view: view, targetState: targetState)
    }
  }
}

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
