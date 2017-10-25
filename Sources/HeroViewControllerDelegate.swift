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

@objc public protocol HeroViewControllerDelegate {
  @objc optional func heroWillStartAnimatingFrom(viewController: UIViewController)
  @objc optional func heroDidEndAnimatingFrom(viewController: UIViewController)
  @objc optional func heroDidCancelAnimatingFrom(viewController: UIViewController)

  @objc optional func heroWillStartTransition()
  @objc optional func heroDidEndTransition()
  @objc optional func heroDidCancelTransition()

  @objc optional func heroWillStartAnimatingTo(viewController: UIViewController)
  @objc optional func heroDidEndAnimatingTo(viewController: UIViewController)
  @objc optional func heroDidCancelAnimatingTo(viewController: UIViewController)
}

// delegate helper
internal extension HeroTransition {
  func closureProcessForHeroDelegate<T: UIViewController>(vc: T, closure: (HeroViewControllerDelegate) -> Void) {
    if let delegate = vc as? HeroViewControllerDelegate {
      closure(delegate)
    }

    if let navigationController = vc as? UINavigationController,
      let delegate = navigationController.topViewController as? HeroViewControllerDelegate {
      closure(delegate)
    } else if let tabBarController = vc as? UITabBarController,
      let delegate = tabBarController.viewControllers?[tabBarController.selectedIndex] as? HeroViewControllerDelegate {
      closure(delegate)
    } else {
      for vc in vc.childViewControllers where vc.isViewLoaded {
        self.closureProcessForHeroDelegate(vc: vc, closure: closure)
      }
    }
  }
}
