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

internal class HeroAnimationConfig: NSObject {
  var modalAnimation: HeroDefaultAnimationType = .auto
  var navigationAnimation: HeroDefaultAnimationType = .auto
  var tabBarAnimation: HeroDefaultAnimationType = .auto
}

public extension UIViewController {
  private struct AssociatedKeys {
    static var previousNavigationDelegate = "previousNavigationDelegate"
    static var previousTabBarDelegate = "previousTabBarDelegate"
    static var heroStoredSnapshots = "heroStoredSnapshots"
    static var heroAnimationConfig = "heroAnimationConfig"
  }

  internal var heroAnimationConfig: HeroAnimationConfig {
    get {
      if let config = objc_getAssociatedObject(self, &AssociatedKeys.heroAnimationConfig) as? HeroAnimationConfig {
        return config
      }
      let config = HeroAnimationConfig()
      self.heroAnimationConfig = config
      return config
    }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroAnimationConfig, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  internal var previousNavigationDelegate: UINavigationControllerDelegate? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.previousNavigationDelegate) as? UINavigationControllerDelegate }
    set { objc_setAssociatedObject(self, &AssociatedKeys.previousNavigationDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  internal var previousTabBarDelegate: UITabBarControllerDelegate? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.previousTabBarDelegate) as? UITabBarControllerDelegate }
    set { objc_setAssociatedObject(self, &AssociatedKeys.previousTabBarDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /// used for .overFullScreen presentation
  internal var heroStoredSnapshots: [UIView]? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.heroStoredSnapshots) as? [UIView]
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.heroStoredSnapshots, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /// default hero animation type for presenting & dismissing modally
  public var heroModalAnimationType: HeroDefaultAnimationType {
    get { return heroAnimationConfig.modalAnimation }
    set { heroAnimationConfig.modalAnimation = newValue }
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
    get { return heroAnimationConfig.navigationAnimation }
    set { heroAnimationConfig.navigationAnimation = newValue }
  }
}

extension UITabBarController {
  /// default hero animation type for switching tabs within the tab bar controller
  public var heroTabBarAnimationType: HeroDefaultAnimationType {
    get { return heroAnimationConfig.tabBarAnimation }
    set { heroAnimationConfig.tabBarAnimation = newValue }
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

  public func hero_presentOnTop(viewController: UIViewController, frame: CGRect) {
    var oldViews = view.flattenedViewHierarchy
    oldViews.removeFirst()
    let hero = HeroIndependentController()
    addChildViewController(viewController)
    viewController.view.frame = frame
    view.addSubview(viewController.view)
    viewController.didMove(toParentViewController: self)
    viewController.view.heroModifiers = [.scale(0.5), .fade]
    hero.transition(rootView: view, fromViews: oldViews, toViews: viewController.view.flattenedViewHierarchy)
  }
}
