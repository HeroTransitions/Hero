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
    for fv in fromViews + toViews{
      guard let options = context[fv, "cascade"],
            let deltaTime = options.getCGFloat(0)
        else { continue }
      
      let directionString = options.get(1)
      let direction = CascadeDirection(directionString ?? "") ?? .topToBottom
      var parentView = fv
      if let _  = fv as? UITableView, let wrapperView = fv.subviews.get(0) {
        parentView = wrapperView
      }
      
      let sortedSubviews = parentView.subviews.filter{
        return context[$0, "matchedHeroID"] == nil
      }.sorted(by: direction.comparator)
      
      let initialDelay = options.getCGFloat(2) ?? 0
      for (i, v) in sortedSubviews.enumerated(){
        let cDelay = CGFloat(i) * deltaTime + initialDelay
        context[v, "delay"] = ["\(cDelay)"]
      }
      
      if let str = options.get(3), let shouldDelayMatchedChild = Bool(str), shouldDelayMatchedChild{
        for v in parentView.subviews{
          if context[v, "matchedHeroID"] != nil, let pairedView = context.pairedView(for: v){
            let cDelay = CGFloat(sortedSubviews.count) * deltaTime + initialDelay
            context[v, "delay"] = ["\(cDelay)"]
            context[pairedView, "delay"] = ["\(cDelay)"]
          }
        }
      }
    }
  }
}
