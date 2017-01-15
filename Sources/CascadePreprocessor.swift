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


public class CascadePreprocessor:HeroPreprocessor {
  public enum CascadeDirection{
    case topToBottom;
    case bottomToTop;
    case leftToRight;
    case rightToLeft;
    case radial(center:CGPoint);
    case inverseRadial(center:CGPoint);
    var comparator:(UIView, UIView) -> Bool{
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

    init?(_ string:String) {
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

  public func process(context:HeroContext, fromViews:[UIView], toViews:[UIView]) {
    process(context:context, views:fromViews)
    process(context:context, views:toViews)
  }
  
  private func process(context:HeroContext, views:[UIView]){
    for (viewIndex, fv) in views.enumerated() {
      guard let (deltaTime, direction, delayMatchedViews) = context[fv]?.cascade else { continue }
      
      var parentView = fv
      if let _  = fv as? UITableView, let wrapperView = fv.subviews.get(0) {
        parentView = wrapperView
      }
      
      let sortedSubviews = parentView.subviews.filter{
        return context.pairedView(for: $0) == nil
        }.sorted(by: direction.comparator)
      
      let initialDelay = context[fv]!.delay
      for (i, v) in sortedSubviews.enumerated(){
        let delay = TimeInterval(i) * deltaTime + initialDelay
        context[v]?.delay = delay
      }
      
      if delayMatchedViews {
        for i in (viewIndex+1)..<views.count{
          let otherView = views[i]
          if otherView.superview == fv.superview {
            break
          }
          if let pairedView = context.pairedView(for: otherView){
            let delay = TimeInterval(sortedSubviews.count) * deltaTime + initialDelay
            context[otherView]!.delay = delay
            context[pairedView]!.delay = delay
          }
        }
      }
    }
  }
}
