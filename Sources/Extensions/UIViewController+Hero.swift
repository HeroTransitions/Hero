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

#if canImport(UIKit)

import UIKit

internal class HeroViewControllerConfig: NSObject {
  var modalAnimation: HeroDefaultAnimationType = .auto
  var navigationAnimation: HeroDefaultAnimationType = .auto
  var tabBarAnimation: HeroDefaultAnimationType = .auto

  var storedSnapshot: UIView?
  weak var previousNavigationDelegate: UINavigationControllerDelegate?
  weak var previousTabBarDelegate: UITabBarControllerDelegate?
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
  var modalAnimationType: HeroDefaultAnimationType {
    get { return config.modalAnimation }
    set { config.modalAnimation = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  var modalAnimationTypeString: String? {
    get { return config.modalAnimation.label }
    set { config.modalAnimation = newValue?.parseOne() ?? .auto }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  var isEnabled: Bool {
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

  @available(*, renamed: "hero.config")
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

  @available(*, renamed: "hero.storedSnapshot")
  internal var heroStoredSnapshot: UIView? {
    get { return hero.config.storedSnapshot }
    set { hero.config.storedSnapshot = newValue }
  }

  @available(*, renamed: "hero.modalAnimationType")
  var heroModalAnimationType: HeroDefaultAnimationType {
    get { return hero.modalAnimationType }
    set { hero.modalAnimationType = newValue }
  }

  @available(*, renamed: "hero.modalAnimationTypeString")
  @IBInspectable var heroModalAnimationTypeString: String? {
    get { return hero.modalAnimationTypeString }
    set { hero.modalAnimationTypeString = newValue }
  }

  @available(*, renamed: "hero.isEnabled")
  @IBInspectable var isHeroEnabled: Bool {
    get { return hero.isEnabled }
    set { hero.isEnabled = newValue }
  }
}

public extension HeroExtension where Base: UINavigationController {

  /// default hero animation type for push and pop within the navigation controller
  var navigationAnimationType: HeroDefaultAnimationType {
    get { return config.navigationAnimation }
    set { config.navigationAnimation = newValue }
  }

  var navigationAnimationTypeString: String? {
    get { return config.navigationAnimation.label }
    set { config.navigationAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UINavigationController {
  @available(*, renamed: "hero.navigationAnimationType")
  public var heroNavigationAnimationType: HeroDefaultAnimationType {
    get { return hero.navigationAnimationType }
    set { hero.navigationAnimationType = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "hero.navigationAnimationTypeString")
  @IBInspectable public var heroNavigationAnimationTypeString: String? {
    get { return hero.navigationAnimationTypeString }
    set { hero.navigationAnimationTypeString = newValue }
  }

  /// This function call the standard setViewControllers() but it also add a completion callback.
   func setViewControllers(viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
		setViewControllers(viewControllers, animated: animated)
		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion?() }
			return
		}
		coordinator.animate(alongsideTransition: nil) { _ in completion?() }
	}
}

public extension HeroExtension where Base: UITabBarController {

  /// default hero animation type for switching tabs within the tab bar controller
  var tabBarAnimationType: HeroDefaultAnimationType {
    get { return config.tabBarAnimation }
    set { config.tabBarAnimation = newValue }
  }

  var tabBarAnimationTypeString: String? {
    get { return config.tabBarAnimation.label }
    set { config.tabBarAnimation = newValue?.parseOne() ?? .auto }
  }
}

public extension UITabBarController {
  @available(*, renamed: "hero.tabBarAnimationType")
  var heroTabBarAnimationType: HeroDefaultAnimationType {
    get { return hero.tabBarAnimationType }
    set { hero.tabBarAnimationType = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "hero.tabBarAnimationTypeString")
  @IBInspectable var heroTabBarAnimationTypeString: String? {
    get { return hero.tabBarAnimationTypeString }
    set { hero.tabBarAnimationTypeString = newValue }
  }
}

public extension HeroExtension where Base: UIViewController {

  /**
   Dismiss the current view controller with animation. Will perform a navigationController.popViewController
   if the current view controller is contained inside a navigationController
   */
  func dismissViewController(completion: (() -> Void)? = nil) {
    if let navigationController = base.navigationController, navigationController.viewControllers.first != base {
      navigationController.popViewController(animated: true)
    } else {
      base.dismiss(animated: true, completion: completion)
    }
  }

  /**
   Unwind to the root view controller using Hero
   */
  func unwindToRootViewController() {
    unwindToViewController { $0.presentingViewController == nil }
  }

  /**
   Unwind to a specific view controller using Hero
   */
  func unwindToViewController(_ toViewController: UIViewController) {
    unwindToViewController { $0 == toViewController }
  }

  func unwindToViewController(withSelector: Selector) {
    unwindToViewController { $0.responds(to: withSelector) }
  }

  /**
   Unwind to a view controller with given class using Hero
   */
  func unwindToViewController(withClass: AnyClass) {
    unwindToViewController { $0.isKind(of: withClass) }
  }

  /**
   Unwind to a view controller that the matchBlock returns true on.
   */
  func unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    var target: UIViewController?
    var current: UIViewController? = base

    while target == nil && current != nil {
      if let childViewControllers = (current as? UINavigationController)?.children ?? current!.navigationController?.children {
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
  func replaceViewController(with next: UIViewController, completion: (() -> Void)? = nil) {
    let hero = next.transitioningDelegate as? HeroTransition ?? Hero.shared

    if hero.isTransitioning {
      print("hero.replaceViewController cancelled because Hero was doing a transition. Use Hero.shared.cancel(animated:false) or Hero.shared.end(animated:false) to stop the transition first before calling hero.replaceViewController.")
      return
    }
    if let navigationController = base.navigationController {
      var vcs = navigationController.children
      if !vcs.isEmpty {
        vcs.removeLast()
        vcs.append(next)
      }
      if navigationController.hero.isEnabled {
        hero.forceNotInteractive = true
      }
      navigationController.setViewControllers(viewControllers: vcs, animated: true, completion: completion)
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
          parentVC?.view.window?.rootViewController = next
        }
      }
    }
  }
}

extension UIViewController {
  @available(*, deprecated, renamed: "hero.dismissViewController()")
  @IBAction public func ht_dismiss(_ sender: UIView) {
    hero.dismissViewController()
  }

  @available(*, deprecated, renamed: "hero.replaceViewController(with:)")
  public func heroReplaceViewController(with next: UIViewController) {
    hero.replaceViewController(with: next)
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, deprecated, renamed: "hero.dismissViewController()")
  @IBAction public func hero_dismissViewController() {
    hero.dismissViewController()
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, deprecated, renamed: "hero.unwindToRootViewController()")
  @IBAction public func hero_unwindToRootViewController() {
    hero.unwindToRootViewController()
  }

  @available(*, deprecated, renamed: "hero.unwindToViewController(_:)")
  public func hero_unwindToViewController(_ toViewController: UIViewController) {
    hero.unwindToViewController(toViewController)
  }

  @available(*, deprecated, renamed: "hero.unwindToViewController(withSelector:)")
  public func hero_unwindToViewController(withSelector: Selector) {
    hero.unwindToViewController(withSelector: withSelector)
  }

  @available(*, deprecated, renamed: "hero_unwindToViewController(withClass:)")
  public func hero_unwindToViewController(withClass: AnyClass) {
    hero.unwindToViewController(withClass: withClass)
  }

  @available(*, deprecated, renamed: "hero.unwindToViewController(withMatchBlock:)")
  public func hero_unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    hero.unwindToViewController(withMatchBlock: withMatchBlock)
  }

  @available(*, deprecated, renamed: "hero.replaceViewController(with:)")
  public func hero_replaceViewController(with next: UIViewController) {
    hero.replaceViewController(with: next)
  }
}

#endif
