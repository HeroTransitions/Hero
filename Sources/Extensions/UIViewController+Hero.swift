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

internal class HeroViewControllerConfig: NSObject {
  var modalAnimation: HeroDefaultAnimationType = .auto
  var navigationAnimation: HeroDefaultAnimationType = .auto
  var tabBarAnimation: HeroDefaultAnimationType = .auto

  var storedSnapshot: UIView?
  var previousNavigationDelegate: UINavigationControllerDelegate?
  var previousTabBarDelegate: UITabBarControllerDelegate?
}

extension UIViewController: HeroCompatible { }
public extension HeroExtension where Base: UIViewController {

  internal var config: HeroViewControllerConfig {
    get {
      if let config = objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.heroConfig) as? HeroViewControllerConfig {
        return config
      }
      let config = HeroViewControllerConfig()
      self.config = config
      return config
    }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /// used for .overFullScreen presentation
  internal var storedSnapshot: UIView? {
    get { return config.storedSnapshot }
    set { config.storedSnapshot = newValue }
  }

  /// default hero animation type for presenting & dismissing modally
  public var modalAnimationType: HeroDefaultAnimationType {
    get { return config.modalAnimation }
    set { config.modalAnimation = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  public var modalAnimationTypeString: String? {
    get { return config.modalAnimation.label }
    set { config.modalAnimation = newValue?.parseOne() ?? .auto }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  public var isEnabled: Bool {
    get {
      return base.transitioningDelegate is HeroTransition
    }
    set {
      guard newValue != isEnabled else { return }
      if newValue {
        base.transitioningDelegate = Hero.shared
        if let navi = base as? UINavigationController {
          base.previousNavigationDelegate = navi.delegate
          navi.delegate = Hero.shared
        }
        if let tab = base as? UITabBarController {
          base.previousTabBarDelegate = tab.delegate
          tab.delegate = Hero.shared
        }
      } else {
        base.transitioningDelegate = nil
        if let navi = base as? UINavigationController, navi.delegate is HeroTransition {
          navi.delegate = base.previousNavigationDelegate
        }
        if let tab = base as? UITabBarController, tab.delegate is HeroTransition {
          tab.delegate = base.previousTabBarDelegate
        }
      }
    }
  }
}

public extension UIViewController {
  fileprivate struct AssociatedKeys {
    static var heroConfig = "heroConfig"
  }

  @available(*, deprecated, message: "Use hero.config instead")
  internal var heroConfig: HeroViewControllerConfig {
    get { return hero.config }
    set { hero.config = newValue }
  }

  internal var previousNavigationDelegate: UINavigationControllerDelegate? {
    get { return hero.config.previousNavigationDelegate }
    set { hero.config.previousNavigationDelegate = newValue }
  }

  internal var previousTabBarDelegate: UITabBarControllerDelegate? {
    get { return hero.config.previousTabBarDelegate }
    set { hero.config.previousTabBarDelegate = newValue }
  }

  @available(*, deprecated, message: "Use hero.storedSnapshot instead")
  internal var heroStoredSnapshot: UIView? {
    get { return hero.config.storedSnapshot }
    set { hero.config.storedSnapshot = newValue }
  }

  @available(*, deprecated, message: "Use hero.modalAnimationType instead")
  public var heroModalAnimationType: HeroDefaultAnimationType {
    get { return hero.modalAnimationType }
    set { hero.modalAnimationType = newValue }
  }

  @available(*, deprecated, message: "Use hero.modalAnimationTypeString instead")
  @IBInspectable public var heroModalAnimationTypeString: String? {
    get { return hero.modalAnimationTypeString }
    set { hero.modalAnimationTypeString = newValue }
  }

  @available(*, deprecated, message: "Use hero.isEnabled instead")
  @IBInspectable public var isHeroEnabled: Bool {
    get { return hero.isEnabled }
    set { hero.isEnabled = newValue }
  }
}

public extension HeroExtension where Base: UINavigationController {

  /// default hero animation type for push and pop within the navigation controller
  public var navigationAnimationType: HeroDefaultAnimationType {
    get { return config.navigationAnimation }
    set { config.navigationAnimation = newValue }
  }

  public var navigationAnimationTypeString: String? {
    get { return config.navigationAnimation.label }
    set { config.navigationAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UINavigationController {
  @available(*, deprecated, message: "Use hero.navigationAnimationType instead")
  public var heroNavigationAnimationType: HeroDefaultAnimationType {
    get { return hero.navigationAnimationType }
    set { hero.navigationAnimationType = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, deprecated, message: "Use hero.navigationAnimationTypeString instead")
  @IBInspectable public var heroNavigationAnimationTypeString: String? {
    get { return hero.navigationAnimationTypeString }
    set { hero.navigationAnimationTypeString = newValue }
  }
}

public extension HeroExtension where Base: UITabBarController {

  /// default hero animation type for switching tabs within the tab bar controller
  public var tabBarAnimationType: HeroDefaultAnimationType {
    get { return config.tabBarAnimation }
    set { config.tabBarAnimation = newValue }
  }

  public var tabBarAnimationTypeString: String? {
    get { return config.tabBarAnimation.label }
    set { config.tabBarAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UITabBarController {
  @available(*, deprecated, message: "Use hero.tabBarAnimationType instead")
  public var heroTabBarAnimationType: HeroDefaultAnimationType {
    get { return hero.tabBarAnimationType }
    set { hero.tabBarAnimationType = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, deprecated, message: "Use hero.tabBarAnimationTypeString instead")
  @IBInspectable public var heroTabBarAnimationTypeString: String? {
    get { return hero.tabBarAnimationTypeString }
    set { hero.tabBarAnimationTypeString = newValue }
  }
}

public extension HeroExtension where Base: UIViewController {

  /**
   Dismiss the current view controller with animation. Will perform a navigationController.popViewController
   if the current view controller is contained inside a navigationController
   */
  public func dismissViewController(completion: (() -> Void)? = nil) {
    if let navigationController = base.navigationController, navigationController.viewControllers.first != base {
      navigationController.popViewController(animated: true)
    } else {
      base.dismiss(animated: true, completion: completion)
    }
  }

  /**
   Unwind to the root view controller using Hero
   */
  public func unwindToRootViewController() {
    unwindToViewController { $0.presentingViewController == nil }
  }

  /**
   Unwind to a specific view controller using Hero
   */
  public func unwindToViewController(_ toViewController: UIViewController) {
    unwindToViewController { $0 == toViewController }
  }

  public func unwindToViewController(withSelector: Selector) {
    unwindToViewController { $0.responds(to: withSelector) }
  }

  /**
   Unwind to a view controller with given class using Hero
   */
  public func unwindToViewController(withClass: AnyClass) {
    unwindToViewController { $0.isKind(of: withClass) }
  }

  /**
   Unwind to a view controller that the matchBlock returns true on.
   */
  public func unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    var target: UIViewController? = nil
    var current: UIViewController? = base

    while target == nil && current != nil {
      if let childViewControllers = (current as? UINavigationController)?.childViewControllers ?? current!.navigationController?.childViewControllers {
        for vc in childViewControllers.reversed() {
          if vc != base, withMatchBlock(vc) {
            target = vc
            break
          }
        }
      }
      if target == nil {
        current = current!.presentingViewController
        if let vc = current, withMatchBlock(vc) == true {
          target = vc
        }
      }
    }

    if let target = target {
      if target.presentedViewController != nil {
        _ = target.navigationController?.popToViewController(target, animated: false)

        let fromVC = base.navigationController ?? base
        let toVC = target.navigationController ?? target

        if target.presentedViewController != fromVC {
          // UIKit's UIViewController.dismiss will jump to target.presentedViewController then perform the dismiss.
          // We overcome this behavior by inserting a snapshot into target.presentedViewController
          // And also force Hero to use the current VC as the fromViewController
          Hero.shared.fromViewController = fromVC
          let snapshotView = fromVC.view.snapshotView(afterScreenUpdates: true)!
          let targetSuperview = toVC.presentedViewController!.view!
          if let visualEffectView = targetSuperview as? UIVisualEffectView {
            visualEffectView.contentView.addSubview(snapshotView)
          } else {
            targetSuperview.addSubview(snapshotView)
          }
        }

        toVC.dismiss(animated: true, completion: nil)
      } else {
        _ = target.navigationController?.popToViewController(target, animated: true)
      }
    } else {
      // unwind target not found
    }
  }

  /**
   Replace the current view controller with another VC on the navigation/modal stack.
   */
  public func replaceViewController(with next: UIViewController, completion: (() -> Void)? = nil) {
    let hero = next.transitioningDelegate as? HeroTransition ?? Hero.shared

    if hero.isTransitioning {
      print("hero.replaceViewController cancelled because Hero was doing a transition. Use Hero.shared.cancel(animated:false) or Hero.shared.end(animated:false) to stop the transition first before calling hero.replaceViewController.")
      return
    }
    if let navigationController = base.navigationController {
      var vcs = navigationController.childViewControllers
      if !vcs.isEmpty {
        vcs.removeLast()
        vcs.append(next)
      }
      if navigationController.hero.isEnabled {
        hero.forceNotInteractive = true
      }
      navigationController.setViewControllers(vcs, animated: true)
    } else if let container = base.view.superview {
      let parentVC = base.presentingViewController
      hero.transition(from: base, to: next, in: container) { [weak base] finished in
        guard let base = base else { return }
        guard finished else { return }

        next.view.window?.addSubview(next.view)
        if let parentVC = parentVC {
          base.dismiss(animated: false) {
            parentVC.present(next, animated: false, completion: completion)
          }
        } else {
          UIApplication.shared.keyWindow?.rootViewController = next
        }
      }
    }
  }
}

extension UIViewController {
  @available(*, deprecated: 0.1.4, message: "use hero.dismissViewController instead")
  @IBAction public func ht_dismiss(_ sender: UIView) {
    hero.dismissViewController()
  }

  @available(*, deprecated: 0.1.4, message: "use hero.replaceViewController(with:) instead")
  public func heroReplaceViewController(with next: UIViewController) {
    hero.replaceViewController(with: next)
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, deprecated, message: "Use hero.dismissViewController instead")
  @IBAction public func hero_dismissViewController() {
    hero.dismissViewController()
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, deprecated, message: "Use hero.unwindToRootViewController instead")
  @IBAction public func hero_unwindToRootViewController() {
    hero.unwindToRootViewController()
  }

  @available(*, deprecated, message: "Use hero.unwindToViewController(_:) instead")
  public func hero_unwindToViewController(_ toViewController: UIViewController) {
    hero.unwindToViewController(toViewController)
  }

  @available(*, deprecated, message: "Use hero.unwindToViewController(withSelector:) instead")
  public func hero_unwindToViewController(withSelector: Selector) {
    hero.unwindToViewController(withSelector: withSelector)
  }

  @available(*, deprecated, message: "Use hero_unwindToViewController(withClass:) instead")
  public func hero_unwindToViewController(withClass: AnyClass) {
    hero.unwindToViewController(withClass: withClass)
  }

  @available(*, deprecated, message: "Use hero.unwindToViewController(withMatchBlock:) instead")
  public func hero_unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    hero.unwindToViewController(withMatchBlock: withMatchBlock)
  }

  @available(*, deprecated, message: "Use hero.replaceViewController(with:) instead")
  public func hero_replaceViewController(with next: UIViewController) {
    hero.replaceViewController(with: next)
  }
}
