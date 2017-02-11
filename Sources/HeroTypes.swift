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

public enum HeroAnimationType {
  public enum Direction {
    case left, right, up, down
  }
  case auto
  case push(direction: Direction)
  case pull(direction: Direction)
  case cover(direction: Direction)
  case uncover(direction: Direction)
  case slide(direction: Direction)
  case zoomSlide(direction: Direction)
  case pageIn(direction: Direction)
  case pageOut(direction: Direction)
  case fade
  indirect case selectBy(presenting:HeroAnimationType, dismissing:HeroAnimationType)
  case none

  public var label:String? {
    let mirror = Mirror(reflecting: self)
    if let associated = mirror.children.first {
      let valuesMirror = Mirror(reflecting: associated.value)
      if valuesMirror.children.count > 0 {
        let parameters = valuesMirror.children.map { ".\($0.value)" }.joined(separator: ",")
        return ".\(associated.label ?? "")(\(parameters))"
      }
      return ".\(associated.label ?? "")(.\(associated.value))"
    }
    return ".\(self)"
  }
}

public protocol HeroPreprocessor {
  weak var context: HeroContext! { get set }
  func process(fromViews: [UIView], toViews: [UIView])
}

public protocol HeroAnimator {
  weak var context: HeroContext! { get set }
  func canAnimate(view: UIView, appearing: Bool) -> Bool
  func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval
  func clean()
  
  func seekTo(timePassed: TimeInterval)
  func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval
  func apply(state: HeroTargetState, to view: UIView)
}

public protocol HeroProgressUpdateObserver {
  func heroDidUpdateProgress(progress: Double)
}

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
