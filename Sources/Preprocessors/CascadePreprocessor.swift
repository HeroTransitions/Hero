//
//  CascadeEffect.swift
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

public enum CascadeDirection {
  case topToBottom
  case bottomToTop
  case leftToRight
  case rightToLeft
  case radial(center:CGPoint)
  case inverseRadial(center:CGPoint)
  var comparator: (UIView, UIView) -> Bool {
    switch self {
    case .topToBottom:
      return { return $0.frame.minY < $1.frame.minY }
    case .bottomToTop:
      return { return $0.frame.maxY == $1.frame.maxY ? $0.frame.maxX > $1.frame.maxX : $0.frame.maxY > $1.frame.maxY }
    case .leftToRight:
      return { return $0.frame.minX < $1.frame.minX }
    case .rightToLeft:
      return { return $0.frame.maxX > $1.frame.maxX }
    case .radial(let center):
      return { return $0.center.distance(center) < $1.center.distance(center) }
    case .inverseRadial(let center):
      return { return $0.center.distance(center) > $1.center.distance(center) }
    }
  }

  init?(_ string: String) {
    switch string {
    case "bottomToTop":
      self = .bottomToTop
    case "leftToRight":
      self = .leftToRight
    case "rightToLeft":
      self = .rightToLeft
    case "topToBottom":
      self = .topToBottom
    default:
      return nil
    }
  }
}

class CascadePreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    process(views: fromViews)
    process(views: toViews)
  }

  func process(views: [UIView]) {
    for view in views {
      guard let (deltaTime, direction, delayMatchedViews) = context[view]?.cascade else { continue }

      var parentView = view
      if view is UITableView, let wrapperView = view.subviews.get(0) {
        parentView = wrapperView
      }

      let sortedSubviews = parentView.subviews.sorted(by: direction.comparator)

      let initialDelay = context[view]!.delay
      let finalDelay = TimeInterval(sortedSubviews.count) * deltaTime + initialDelay

      for (i, subview) in sortedSubviews.enumerated() {
        let delay = TimeInterval(i) * deltaTime + initialDelay

        func applyDelay(view: UIView) {
          if context.pairedView(for: view) == nil {
            context[view]?.delay = delay
          } else if delayMatchedViews, let paired = context.pairedView(for: view) {
            context[view]?.delay = finalDelay
            context[paired]?.delay = finalDelay
          }
          for subview in view.subviews {
            applyDelay(view: subview)
          }
        }

        applyDelay(view: subview)
      }
    }
  }
}
