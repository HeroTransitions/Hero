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

class SourcePreprocessor:BasePreprocessor {
  override public func process(fromViews:[UIView], toViews:[UIView]) {
    for fv in fromViews{
      guard let id = context[fv]?.source,
            let tv = context.destinationView(for: id) else { continue }
      prepareFor(view: fv, targetView: tv)
    }
    for tv in toViews {
      guard let id = context[tv]?.source,
            let fv = context.sourceView(for: id) else { continue }
      prepareFor(view: tv, targetView: fv)
    }
  }
}

extension SourcePreprocessor {
  
  fileprivate func prepareFor(view:UIView, targetView:UIView){
    let targetPos = context.container.convert(targetView.layer.position, from: targetView.superview!)

    var state = context[view]!

    // remove incompatible options
    state.transform = nil
    state.size = nil

    state.position = targetPos
    if view.bounds.size != targetView.bounds.size {
      state.size = targetView.bounds.size
    }
    if view.layer.cornerRadius != targetView.layer.cornerRadius {
      state.cornerRadius = targetView.layer.cornerRadius
    }
    if view.layer.transform != targetView.layer.transform {
      state.transform = targetView.layer.transform
    }
    context[view] = state
  }
}
