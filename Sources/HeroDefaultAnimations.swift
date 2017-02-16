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

public enum HeroDefaultAnimationType {
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
  case zoom
  case zoomOut
  indirect case selectBy(presenting: HeroDefaultAnimationType, dismissing: HeroDefaultAnimationType)
  case none

  public var label: String? {
    let mirror = Mirror(reflecting: self)
    if let associated = mirror.children.first {
      let valuesMirror = Mirror(reflecting: associated.value)
      if !valuesMirror.children.isEmpty {
        let parameters = valuesMirror.children.map { ".\($0.value)" }.joined(separator: ",")
        return ".\(associated.label ?? "")(\(parameters))"
      }
      return ".\(associated.label ?? "")(.\(associated.value))"
    }
    return ".\(self)"
  }
}

internal extension Hero {

  func shift(direction: HeroDefaultAnimationType.Direction, appearing: Bool, size: CGSize? = nil, transpose: Bool = false) -> CGPoint {
    let size = size ?? container.bounds.size
    let rtn: CGPoint
    switch direction {
    case .left, .right:
      rtn = CGPoint(x: (direction == .right) == appearing ? -size.width : size.width, y: 0)
    case .up, .down:
      rtn = CGPoint(x: 0, y: (direction == .down) == appearing ? -size.height : size.height)
    }
    if transpose {
      return CGPoint(x: rtn.y, y: rtn.x)
    }
    return rtn
  }

  func prepareDefaultAnimation() {
    if case .auto = defaultAnimation {
      if inNavigationController, let navAnim = toViewController?.navigationController?.heroNavigationAnimationType {
        defaultAnimation = navAnim
      } else if inTabBarController, let tabAnim = toViewController?.tabBarController?.heroTabBarAnimationType {
        defaultAnimation = tabAnim
      } else if let modalAnim = toViewController?.heroModalAnimationType {
        defaultAnimation = modalAnim
      }
    }

    if case .selectBy(let presentAnim, let dismissAnim) = defaultAnimation {
      defaultAnimation = presenting ? presentAnim : dismissAnim
    }

    if case .auto = defaultAnimation {
      if animators.contains(where: { $0.canAnimate(view: toView, appearing: true) || $0.canAnimate(view: fromView, appearing: false) }) {
        defaultAnimation = .none
      } else if inNavigationController {
        defaultAnimation = presenting ? .push(direction:.left) : .pull(direction:.right)
      } else if inTabBarController {
        defaultAnimation = presenting ? .slide(direction:.left) : .slide(direction:.right)
      } else {
        defaultAnimation = .fade
      }
    }

    if case .none = defaultAnimation {
      return
    }

    context[fromView] = [.timingFunction(.standard), .duration(0.35)]
    context[toView] = [.timingFunction(.standard), .duration(0.35)]

    let shadowState: [HeroModifier] = [.shadowOpacity(0.5),
                                       .shadowColor(.black),
                                       .shadowRadius(5),
                                       .shadowOffset(.zero),
                                       .masksToBounds(false)]
    switch defaultAnimation {
    case .push(let direction):
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)),
                                           .shadowOpacity(0),
                                           .beginWith(modifiers: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false) / 3),
                                             .overlay(color: .black, opacity: 0.3),
                                             .timingFunction(.deceleration)])
    case .pull(let direction):
      insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)),
                                             .shadowOpacity(0),
                                             .beginWith(modifiers: shadowState)])
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true) / 3),
                                           .overlay(color: .black, opacity: 0.3)])
    case .slide(let direction):
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false))])
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true))])
    case .zoomSlide(let direction):
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)), .scale(0.8)])
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)), .scale(0.8)])
    case .cover(let direction):
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)),
                                           .shadowOpacity(0),
                                           .beginWith(modifiers: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.overlay(color: .black, opacity: 0.3),
                                             .timingFunction(.deceleration)])
    case .uncover(let direction):
      insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)),
                                             .shadowOpacity(0),
                                             .beginWith(modifiers: shadowState)])
      context[toView]!.append(contentsOf: [.overlay(color: .black, opacity: 0.3)])
    case .pageIn(let direction):
      context[toView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: true)),
                                           .shadowOpacity(0),
                                           .beginWith(modifiers: shadowState),
                                           .timingFunction(.deceleration)])
      context[fromView]!.append(contentsOf: [.scale(0.7),
                                             .overlay(color: .black, opacity: 0.3),
                                             .timingFunction(.deceleration)])
    case .pageOut(let direction):
      insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.translate(shift(direction: direction, appearing: false)),
                                             .shadowOpacity(0),
                                             .beginWith(modifiers: shadowState)])
      context[toView]!.append(contentsOf: [.scale(0.7),
                                           .overlay(color: .black, opacity: 0.3)])
    case .fade:
      // TODO: clean up this. overFullScreen logic shouldn't be here
      if !(fromOverFullScreen && !presenting) {
        context[toView] = [.fade]
      }

      #if os(tvOS)
        context[fromView] = [.fade]
      #else
        if (!presenting && toOverFullScreen) || !fromView.isOpaque || (fromView.backgroundColor?.alphaComponent ?? 1) < 1 {
          context[fromView] = [.fade]
        }
      #endif

      context[toView]!.append(.durationMatchLongest)
      context[fromView]!.append(.durationMatchLongest)
    case .zoom:
      insertToViewFirst = true
      context[fromView]!.append(contentsOf: [.scale(1.3), .fade])
      context[toView]!.append(contentsOf: [.scale(0.7)])
    case .zoomOut:
      context[toView]!.append(contentsOf: [.scale(1.3), .fade])
      context[fromView]!.append(contentsOf: [.scale(0.7)])
    default:
      fatalError("Not implemented")
    }
  }
}
