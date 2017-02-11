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

class IgnoreSubviewModifiersPreprocessor: BasePreprocessor {
  override func process(fromViews: [UIView], toViews: [UIView]) {
    process(views:fromViews)
    process(views:toViews)
  }

  func process(views: [UIView]) {
    for (viewIndex, view) in views.enumerated() {
      guard let recursive = context[view]?.ignoreSubviewModifiers else { continue }
      var parentView = view
      if let _  = view as? UITableView, let wrapperView = view.subviews.get(0) {
        parentView = wrapperView
      }

      if recursive {
        for i in (viewIndex+1)..<views.count {
          let childView = views[i]
          if childView.superview == view.superview {
            break
          }
          context[childView] = nil
        }
      } else {
        for subview in parentView.subviews {
          context[subview] = nil
        }
      }
    }
  }
}
