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

func viewState(for view:UIView, with modifiers:HeroModifiers) -> [String:Any]{
  var rtn = [String:Any]()
  for (className, option) in modifiers{
    switch className {
    case "size":
      if let size = CGSize(modifierParameters:option){
        rtn["bounds.size"] = NSValue(cgSize:size)
      }
    case "position":
      if let point = CGPoint(modifierParameters:option){
        rtn["position"] = NSValue(cgPoint:point)
      }
    case "fade":
      rtn["opacity"] = NSNumber(value: 0)
    case "cornerRadius":
      if let cr = option.getFloat(0) {
        rtn["cornerRadius"] = NSNumber(value: cr)
      }
    case "transform":
      if let transform = CATransform3D(modifierParameters: option){
        rtn["transform"] = NSValue(caTransform3D:transform)
      }
    case "perspective", "scale", "translate", "rotate":
      var t = (rtn["transform"] as? NSValue)?.caTransform3DValue ?? view.layer.transform
      switch className {
      case "perspective":
        t.m34 = 1.0 / -(option.getCGFloat(0) ?? 500)
      case "scale":
        if option.count == 1{
          // default scale on both x & y
          t = CATransform3DScale(t,
                                 CGFloat(Float(option.get(0) ?? "") ?? 1),
                                 CGFloat(Float(option.get(0) ?? "") ?? 1),
                                 1)
        } else {
          t = CATransform3DScale(t,
                                 CGFloat(Float(option.get(0) ?? "") ?? 1),
                                 CGFloat(Float(option.get(1) ?? "") ?? 1),
                                 CGFloat(Float(option.get(2) ?? "") ?? 1))
        }
      case "translate":
        t = CATransform3DTranslate(t,
                                   option.getCGFloat(0) ?? 0,
                                   option.getCGFloat(1) ?? 0,
                                   option.getCGFloat(2) ?? 0)
      case "rotate":
        if option.count == 1{
          // default rotate on z axis
          t = CATransform3DRotate(t, CGFloat(Float(option.get(0) ?? "") ?? 0), 0, 0, 1)
        } else {
          t = CATransform3DRotate(t, CGFloat(Float(option.get(0) ?? "") ?? 0), 1, 0, 0)
          t = CATransform3DRotate(t, CGFloat(Float(option.get(1) ?? "") ?? 0), 0, 1, 0)
          t = CATransform3DRotate(t, CGFloat(Float(option.get(2) ?? "") ?? 0), 0, 0, 1)
        }
      default: break
      }
      rtn["transform"] = NSValue(caTransform3D:t)
    default: break
    }
  }
  return rtn
}
