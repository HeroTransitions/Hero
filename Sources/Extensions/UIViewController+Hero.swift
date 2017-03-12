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

public extension UIViewController {
  private struct AssociatedKeys {
    static var heroConfig = "heroConfig"
  }

  internal var heroConfig: HeroViewControllerConfig {
    get {
      if let config = objc_getAssociatedObject(self, &AssociatedKeys.heroConfig) as? HeroViewControllerConfig {
        return config
      }
      let config = HeroViewControllerConfig()
      self.heroConfig = config
      return config
    }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  internal var previousNavigationDelegate: UINavigationControllerDelegate? {
    get { return heroConfig.previousNavigationDelegate }
    set { heroConfig.previousNavigationDelegate = newValue }
  }

  internal var previousTabBarDelegate: UITabBarControllerDelegate? {
    get { return heroConfig.previousTabBarDelegate }
    set { heroConfig.previousTabBarDelegate = newValue }
  }

  /// used for .overFullScreen presentation
  internal var heroStoredSnapshot: UIView? {
    get { return heroConfig.storedSnapshot }
    set { heroConfig.storedSnapshot = newValue }
  }

  /// default hero animation type for presenting & dismissing modally
  public var heroModalAnimationType: HeroDefaultAnimationType {
    get { return heroConfig.modalAnimation }
    set { heroConfig.modalAnimation = newValue }
  }

  @IBInspectable public var heroModalAnimationTypeString: String? {
    get { return heroConfig.modalAnimation.label }
    set { heroConfig.modalAnimation = newValue?.parseOne() ?? .auto }
  }

  @IBInspectable public var isHeroEnabled: Bool {
    get {
      return transitioningDelegate is Hero
    }

    set {
      guard newValue != isHeroEnabled else { return }
      if newValue {
        transitioningDelegate = Hero.shared
        if let navi = self as? UINavigationController {
          previousNavigationDelegate = navi.delegate
          navi.delegate = Hero.shared
        }
        if let tab = self as? UITabBarController {
          previousTabBarDelegate = tab.delegate
          tab.delegate = Hero.shared
        }
      } else {
        transitioningDelegate = nil
        if let navi = self as? UINavigationController, navi.delegate is Hero {
          navi.delegate = previousNavigationDelegate
        }
        if let tab = self as? UITabBarController, tab.delegate is Hero {
          tab.delegate = previousTabBarDelegate
        }
      }
    }
  }
}

extension UINavigationController {
  /// default hero animation type for push and pop within the navigation controller
  public var heroNavigationAnimationType: HeroDefaultAnimationType {
    get { return heroConfig.navigationAnimation }
    set { heroConfig.navigationAnimation = newValue }
  }

  @IBInspectable public var heroNavigationAnimationTypeString: String? {
    get { return heroConfig.navigationAnimation.label }
    set { heroConfig.navigationAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UITabBarController {
  /// default hero animation type for switching tabs within the tab bar controller
  public var heroTabBarAnimationType: HeroDefaultAnimationType {
    get { return heroConfig.tabBarAnimation }
    set { heroConfig.tabBarAnimation = newValue }
  }

  @IBInspectable public var heroTabBarAnimationTypeString: String? {
    get { return heroConfig.tabBarAnimation.label }
    set { heroConfig.tabBarAnimation = newValue?.parseOne() ?? .auto }
  }
}

extension UIViewController {
  @available(*, deprecated: 0.1.4, message: "use hero_dismissViewController instead")
  @IBAction public func ht_dismiss(_ sender: UIView) {
    hero_dismissViewController()
  }

  @available(*, deprecated: 0.1.4, message: "use hero_replaceViewController(with:) instead")
  public func heroReplaceViewController(with next: UIViewController) {
    hero_replaceViewController(with: next)
  }

  /**
   Dismiss the current view controller with animation. Will perform a navigationController.popViewController
   if the current view controller is contained inside a navigationController
   */
  @IBAction public func hero_dismissViewController() {
    if let navigationController = navigationController, navigationController.viewControllers.first != self {
      navigationController.popViewController(animated: true)
    } else {
      dismiss(animated: true, completion: nil)
    }
  }

  /**
   Unwind to the root view controller using Hero
   */
  @IBAction public func hero_unwindToRootViewController() {
    hero_unwindToViewController { $0.presentingViewController == nil }
  }

  /**
   Unwind to a specific view controller using Hero
   */
  public func hero_unwindToViewController(_ toViewController: UIViewController) {
    hero_unwindToViewController { $0 == toViewController }
  }

  /**
   Unwind to a view controller that responds to the given selector using Hero
   */
  public func hero_unwindToViewController(withSelector: Selector) {
    hero_unwindToViewController { $0.responds(to: withSelector) }
  }

  /**
   Unwind to a view controller with given class using Hero
   */
  public func hero_unwindToViewController(withClass: AnyClass) {
    hero_unwindToViewController { $0.isKind(of: withClass) }
  }

  /**
   Unwind to a view controller that the matchBlock returns true on.
   */
  public func hero_unwindToViewController(withMatchBlock: (UIViewController) -> Bool) {
    var target: UIViewController? = nil
    var current: UIViewController? = self

    while target == nil && current != nil {
      if let childViewControllers = (current as? UINavigationController)?.childViewControllers ?? current!.navigationController?.childViewControllers {
        for vc in childViewControllers.reversed() {
          if vc != self, withMatchBlock(vc) {
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
        let _ = target.navigationController?.popToViewController(target, animated: false)

        let fromVC = self.navigationController ?? self
        let toVC = target.navigationController ?? target

        if target.presentedViewController != fromVC {
          // UIKit's UIViewController.dismiss will jump to target.presentedViewController then perform the dismiss.
          // We overcome this behavior by inserting a snapshot into target.presentedViewController
          // And also force Hero to use the current VC as the fromViewController
          Hero.shared.fromViewController = fromVC
          let snapshotView = fromVC.view.snapshotView(afterScreenUpdates: true)!
          toVC.presentedViewController!.view.addSubview(snapshotView)
        }

        toVC.dismiss(animated: true, completion: nil)
      } else {
        let _ = target.navigationController?.popToViewController(target, animated: true)
      }
    } else {
      // unwind target not found
    }
  }

  /**
   Replace the current view controller with another VC on the navigation/modal stack.
   */
  public func hero_replaceViewController(with next: UIViewController) {
    if Hero.shared.transitioning {
      print("hero_replaceViewController cancelled because Hero was doing a transition. Use Hero.shared.cancel(animated:false) or Hero.shared.end(animated:false) to stop the transition first before calling hero_replaceViewController.")
      return
    }
    if let navigationController = navigationController {
      var vcs = navigationController.childViewControllers
      if !vcs.isEmpty {
        vcs.removeLast()
        vcs.append(next)
      }
      if navigationController.isHeroEnabled {
        Hero.shared.forceNotInteractive = true
      }
      navigationController.setViewControllers(vcs, animated: true)
    } else if let container = view.superview {
      let parentVC = presentingViewController
      Hero.shared.transition(from: self, to: next, in: container) { finished in
        if finished {
          UIApplication.shared.keyWindow?.addSubview(next.view)

          if let parentVC = parentVC {
            self.dismiss(animated: false) {
              parentVC.present(next, animated: false, completion:nil)
            }
          } else {
            UIApplication.shared.keyWindow?.rootViewController = next
          }
        }
      }
    }
  }
}
