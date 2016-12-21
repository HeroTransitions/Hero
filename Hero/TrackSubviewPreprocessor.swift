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

public class TrackSubviewPreprocessor:HeroPreprocessor {
  public func process(context:HeroContext, fromViews:[UIView], toViews:[UIView]) {
    process(context: context, views: fromViews, appearing:false)
    process(context: context, views: toViews, appearing:true)
  }
  
  private func process(context:HeroContext, views:[UIView], appearing:Bool){
    for (i, zoomView) in views.enumerated(){
      guard context[zoomView, "trackSubview"] != nil else { continue }
      var pairedSubview:(UIView, UIView)?
      for j in i+1..<views.count{
        if views[j].superview == zoomView.superview{
          break
        }
        if let pairedView = context.pairedView(for: views[j]){
          pairedSubview = (views[j], pairedView)
          break
        }
      }
      if let (from, to) = pairedSubview{
        let scale = to.frame.width / from.frame.width
        let diff = zoomView.bounds.center - zoomView.convert(from.center, from: from.superview!)
        let final = context.container.convert(to.center, from: to.superview!) + diff * scale
        let size = zoomView.bounds.size * scale
        context[zoomView] = "trackSubview position(\(final.x),\(final.y)) bounds(0,0,\(size.width),\(size.height)) clearSubviewModifiers fade"
        context[zoomView, "arc"] = context[appearing ? from : to, "arc"]
      }
    }
  }
}
