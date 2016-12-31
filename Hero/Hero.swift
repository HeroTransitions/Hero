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

internal class Hero:NSObject {
  weak var toViewController:UIViewController?
  weak var fromViewController:UIViewController?
  
  var interactive:Bool = false

  var container: UIView!{
    return animatingViewContainer
  }
  var transitionContainer:UIView!
  var presenting = true

  fileprivate var completionCallback:(() -> Void)?
  
  fileprivate var maxDurationNeeded:TimeInterval = 0.0
  fileprivate var inContainerController = false
  fileprivate weak var transitionContext:UIViewControllerContextTransitioning?
  
  fileprivate var toView:UIView { return toViewController!.view }
  fileprivate var fromView:UIView { return fromViewController!.view }
  
  fileprivate var context:HeroContext!
  fileprivate var animatingViewContainer:UIView!
  
  fileprivate var processors:[HeroPreprocessor]!
  fileprivate var animators:[HeroAnimator]!
  fileprivate var plugins:[HeroPlugin]!
  
  fileprivate static let builtInProcessors:[HeroPreprocessor] = [
    ClearModifierPreprocessor(),
    ViewToViewPreprocessor(),
    SourceIDPreprocessor(),
    CascadePreprocessor()
  ]

  fileprivate static let builtInAnimator = [
    HeroDefaultAnimator()
  ]
  
  fileprivate static var enabledPlugins:[HeroPlugin.Type] = []
  var lastProgress:Double = 0
  fileprivate var animatorViews:[([UIView],[UIView])]!
}

internal extension Hero {
  static func isEnabled(plugin:HeroPlugin.Type) -> Bool{
    return enabledPlugins.index(where: { return $0 == plugin}) != nil
  }
  
  static func enable(plugin:HeroPlugin.Type){
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }

  static func disable(plugin:HeroPlugin.Type){
    if let index = enabledPlugins.index(where: { return $0 == plugin}){
      enabledPlugins.remove(at: index)
    }
  }
}

internal extension Hero {
  func start(){
    if plugins == nil{
      plugins = Hero.enabledPlugins.map({ return $0.init() })
    }
    processors = Hero.builtInProcessors
    animators = Hero.builtInAnimator
    
    // swift 3 bug. no idea why it wont let me to use append(contentsOf:) or + operator
    for p in plugins{
      processors.append(p)
      animators.append(p)
    }
    
    if let delegate = fromViewController as? HeroViewControllerDelegate{
      delegate.heroWillStartAnimatingTo?(viewController: toViewController!)
    }
    if let navigationController = fromViewController as? UINavigationController,
      let delegate = navigationController.topViewController as? HeroViewControllerDelegate{
      delegate.heroWillStartAnimatingTo?(viewController: toViewController!)
    }
    if let delegate = toViewController as? HeroViewControllerDelegate{
      delegate.heroWillStartAnimatingFrom?(viewController: fromViewController!)
    }
    if let navigationController = toViewController as? UINavigationController,
      let delegate = navigationController.topViewController as? HeroViewControllerDelegate{
      delegate.heroWillStartAnimatingFrom?(viewController: fromViewController!)
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

    toView.frame = transitionContainer.bounds
    toView.updateConstraints()
    toView.setNeedsLayout()
    toView.layoutIfNeeded()
    
    context = HeroContext(container:animatingViewContainer, fromView: fromView, toView:toView)
    
    // ask each preprocessor to process
    for p in processors{
      p.process(context:context, fromViews: context.fromViews, toViews: context.toViews)
    }
    animatorViews = []
    var fromViews = context.fromViews
    var toViews = context.toViews
    for a in self.animators.reversed(){
      let currentFromViews = fromViews.filterInPlace{ [context] (view:UIView) -> Bool in
        return !a.canAnimate(context: context!, view: view, appearing: false)
      }
      let currentToViews = toViews.filterInPlace{ [context] (view:UIView) -> Bool in
        return !a.canAnimate(context: context!, view: view, appearing: true)
      }
      animatorViews.insert((currentFromViews, currentToViews), at: 0)
    }

    if fromViews.first == fromView && toViews.first == toView {
      // if no animator can animate toView & fromView, set the effect to fade // i.e. default effect
      context[toView, "fade"] = []
      animatorViews[0].1.insert(toView, at: 0)
    }

    // wait for a frame if using navigation controller.
    // a bug with navigation controller. the snapshot is not captured if animating immediately
    delay(inContainerController && presenting ? 0.02 : 0) {
      for (currentFromViews, currentToViews) in self.animatorViews {
        // auto hide all animated views
        for v in currentFromViews{
          v.isHidden = true
        }
        for v in currentToViews{
          v.isHidden = true
        }
      }
      
      for (i, a) in self.animators.enumerated(){
        let duration = a.animate(context: self.context,
                                 fromViews: self.animatorViews[i].0,
                                 toViews: self.animatorViews[i].1)
        self.maxDurationNeeded = max(self.maxDurationNeeded, duration)
      }
      
      // we are done with setting up, so remove the covering snapshot
      completeSnapshot.removeFromSuperview()
      
      if self.interactive{
        if self.lastProgress == 0{
          self.update(progress: 0)
        }
      } else {
        delay(self.maxDurationNeeded) {
          self.end(finished: true)
        }
      }
    }
  }

  internal func transition(from:UIViewController, to:UIViewController, in view:UIView, completion:(() -> Void)? = nil){
    inContainerController = false
    presenting = true
    transitionContainer = view
    fromViewController = from
    toViewController = to
    completionCallback = completion
    start()
  }
  
  internal func end(finished:Bool){
    guard self.transitionContainer != nil else { return }
    for (i, animator) in self.animators.enumerated(){
      animator.clean()
      for v in self.animatorViews[i].0{
        v.isHidden = false
      }
      for v in self.animatorViews[i].1{
        v.isHidden = false
      }
    }
    
    // move fromView & toView back from animatingViewContainer
    self.transitionContainer.addSubview(finished ? self.toView : self.fromView)

    if presenting != finished, !inContainerController{
      // bug: http://openradar.appspot.com/radar?id=5320103646199808
      UIApplication.shared.keyWindow!.addSubview(toView)
    }

    animatingViewContainer.removeFromSuperview()
    animatingViewContainer = nil
    animatorViews = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    inContainerController = false
    interactive = false
    lastProgress = 0
    maxDurationNeeded = 0
    
    self.transitionContainer!.isUserInteractionEnabled = true
    let transitionContext = self.transitionContext
    let fvc = fromViewController!
    let tvc = toViewController!
    let completion = completionCallback

    self.transitionContainer = nil
    self.transitionContext = nil
    fromViewController = nil
    toViewController = nil
    completionCallback = nil
    
    transitionContext?.completeTransition(finished)
    completion?()

    if let delegate = fvc as? HeroViewControllerDelegate{
      delegate.heroDidEndAnimatingTo?(viewController: tvc)
    }
    if let nc = fvc as? UINavigationController,
       let delegate = nc.topViewController as? HeroViewControllerDelegate{
      delegate.heroDidEndAnimatingTo?(viewController: tvc)
    }
    if let delegate = tvc as? HeroViewControllerDelegate{
      delegate.heroDidEndAnimatingFrom?(viewController: fvc)
    }
    if let nc = tvc as? UINavigationController,
      let delegate = nc.topViewController as? HeroViewControllerDelegate{
      delegate.heroDidEndAnimatingFrom?(viewController: fvc)
    }
  }
}

extension Hero:HeroInteractiveContext{
  func update(progress: Double) {
    let p = max(0, min(1, progress))
    lastProgress = p
    for a in animators{
      a.seekTo(timePassed: p * maxDurationNeeded)
    }
    transitionContext?.updateInteractiveTransition(CGFloat(p))
  }
  func end() {
    var maxTime:TimeInterval = 0
    for a in animators{
      maxTime = max(maxTime, a.resume(timePassed:lastProgress*maxDurationNeeded, reverse: false))
    }
    transitionContext?.finishInteractiveTransition()
    delay(maxTime){
      self.end(finished: true)
    }
  }
  func cancel() {
    var maxTime:TimeInterval = 0
    for a in animators{
      maxTime = max(maxTime, a.resume(timePassed:lastProgress*maxDurationNeeded, reverse: true))
    }
    transitionContext?.cancelInteractiveTransition()
    delay(maxTime){
      self.end(finished: false)
    }
  }
  func temporarilySet(view:UIView, with modifiers:String){
    let modifiers = HeroContext.extractModifiers(modifierString: modifiers)
    if let otherView = context.pairedView(for: view){
      for a in animators{
        a.temporarilySet(view: otherView, to: modifiers)
      }
    }
    for a in animators{
      a.temporarilySet(view: view, to: modifiers)
    }
  }
}

extension Hero:UIViewControllerAnimatedTransitioning {
  func animateTransition(using context: UIViewControllerContextTransitioning) {
    if transitionContext != nil {
      return
    }
    transitionContext = context
    fromViewController = fromViewController ?? context.viewController(forKey: .from)
    toViewController = toViewController ?? context.viewController(forKey: .to)
    transitionContainer = context.containerView
    start()
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.375
  }
}

extension Hero:UIViewControllerTransitioningDelegate {
  fileprivate var interactiveTransitioning:UIViewControllerInteractiveTransitioning?{
    if let fvc = fromViewController as? HeroViewControllerDelegate{
      interactive = fvc.wantInteractiveHeroTransition?(context: self) ?? false
    }
    if !interactive, let navigationController = fromViewController as? UINavigationController,
      let fvc = navigationController.topViewController as? HeroViewControllerDelegate{
      interactive = fvc.wantInteractiveHeroTransition?(context: self) ?? false
    }
    if !interactive{
      plugins = Hero.enabledPlugins.map({ return $0.init() })
      for p in plugins{
        if p.wantInteractiveHeroTransition(context: self){
          interactive = true
          break
        }
      }
    }
    return interactive ? self : nil
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    self.fromViewController = fromViewController ?? presenting
    self.toViewController = toViewController ?? presented
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = false
    self.fromViewController = fromViewController ?? dismissed
    return self
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension Hero:UIViewControllerInteractiveTransitioning{
  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    animateTransition(using: transitionContext)
  }
}

extension Hero:UINavigationControllerDelegate {
  
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = operation == .push
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inContainerController = true
    return self
  }
  
  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransitioning
  }
}

extension Hero:UITabBarControllerDelegate{
  func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?{
    return interactiveTransitioning
  }
  
  func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
    self.presenting = true
    self.fromViewController = fromViewController ?? fromVC
    self.toViewController = toViewController ?? toVC
    self.inContainerController = true
    return self
  }
}
