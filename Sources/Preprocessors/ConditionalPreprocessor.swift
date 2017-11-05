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

public struct HeroConditionalContext {
  internal weak var hero: HeroTransition!
  public weak var view: UIView!

  public private(set) var isAppearing: Bool

  public var isPresenting: Bool {
    return hero.isPresenting
  }
  public var isInTabbarController: Bool {
    return hero.inTabBarController
  }
  public var isInNavbarController: Bool {
    return hero.inNavigationController
  }
  public var isMatched: Bool {
    return matchedView != nil
  }
  public var isAncestorViewMatched: Bool {
    return matchedAncestorView != nil
  }

  public var matchedView: UIView? {
    return hero.context.pairedView(for: view)
  }
  public var matchedAncestorView: (UIView, UIView)? {
    var current = view.superview
    while let ancestor = current, ancestor != hero.context.container {
      if let pairedView = hero.context.pairedView(for: ancestor) {
        return (ancestor, pairedView)
      }
      current = ancestor.superview
    }
    return nil
  }

  public var fromViewController: UIViewController {
    return hero.fromViewController!
  }
  public var toViewController: UIViewController {
    return hero.toViewController!
  }
  public var currentViewController: UIViewController {
    return isAppearing ? toViewController : fromViewController
  }
  public var otherViewController: UIViewController {
    return isAppearing ? fromViewController : toViewController
  }
}

class ConditionalPreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    process(views: fromViews, appearing: false)
    process(views: toViews, appearing: true)
  }

  func process(views: [UIView], appearing: Bool) {
    for view in views {
      guard let conditionalModifiers = context[view]?.conditionalModifiers else { continue }
      for (condition, modifiers) in conditionalModifiers {
        if condition(HeroConditionalContext(hero: hero, view: view, isAppearing: appearing)) {
          context[view]!.append(contentsOf: modifiers)
        }
      }
    }
  }
}
