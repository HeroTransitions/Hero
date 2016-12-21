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

internal extension Array{
  func get(_ index:Int) -> Element?{
    if index < count{
      return self[index]
    }
    return nil
  }
  func getCGFloat(_ index:Int) -> CGFloat?{
    if index < count, let s = self[index] as? String, let f = Float(s){
      return CGFloat(f)
    }
    return nil
  }
  func getDouble(_ index:Int) -> Double?{
    if index < count, let s = self[index] as? String, let f = Double(s){
      return f
    }
    return nil
  }
  func getFloat(_ index:Int) -> Float?{
    if index < count, let s = self[index] as? String, let f = Float(s){
      return f
    }
    return nil
  }
  func getBool(_ index:Int) -> Bool?{
    if index < count, let s = self[index] as? String, let f = Bool(s){
      return f
    }
    return nil
  }
  
  mutating func filterInPlace(_ comparator:(Element)->Bool) -> Array<Element>{
    var array2:Array<Element> = []
    self = self.filter { (element) -> Bool in
      if comparator(element) {
        return true
      } else{
        array2.append(element)
        return false
      }
    }
    return array2
  }
}

internal extension CGPoint{
  var modifierParameters:[String]{
    return ["\(x)","\(y)"]
  }
  init?(modifierParameters:[String]){
    if let x = modifierParameters.getCGFloat(0),
       let y = modifierParameters.getCGFloat(1){
      self.x = x
      self.y = y
    } else {
      return nil
    }
  }
}

internal extension CGSize{
  var modifierParameters:[String]{
    return ["\(width)","\(height)"]
  }
  init?(modifierParameters:[String]){
    if let w = modifierParameters.getCGFloat(0),
      let h = modifierParameters.getCGFloat(1){
      self.width = w
      self.height = h
    } else {
      return nil
    }
  }
}


internal extension CGRect{
  var modifierParameters:[String]{
    return ["\(origin.x)","\(origin.y)","\(size.width)","\(size.height)"]
  }
  init?(modifierParameters:[String]){
    if let x = modifierParameters.getCGFloat(0),
      let y = modifierParameters.getCGFloat(1),
      let w = modifierParameters.getCGFloat(2),
      let h = modifierParameters.getCGFloat(3){
      origin = CGPoint(x: x, y: y)
      size = CGSize(width: w, height: h)
    } else {
      return nil
    }
  }
}

internal extension CATransform3D{
  var modifierParameters:[String]{
    return ["\(m11)", "\(m12)", "\(m13)", "\(m14)",
      "\(m21)", "\(m22)", "\(m23)", "\(m24)",
      "\(m31)", "\(m32)", "\(m33)", "\(m34)",
      "\(m41)", "\(m42)", "\(m43)", "\(m44)"]
  }
  init?(modifierParameters:[String]){
    if let m11 = modifierParameters.getCGFloat(0),
      let m12 = modifierParameters.getCGFloat(1),
      let m13 = modifierParameters.getCGFloat(2),
      let m14 = modifierParameters.getCGFloat(3),
      let m21 = modifierParameters.getCGFloat(4),
      let m22 = modifierParameters.getCGFloat(5),
      let m23 = modifierParameters.getCGFloat(6),
      let m24 = modifierParameters.getCGFloat(7),
      let m31 = modifierParameters.getCGFloat(8),
      let m32 = modifierParameters.getCGFloat(9),
      let m33 = modifierParameters.getCGFloat(10),
      let m34 = modifierParameters.getCGFloat(11),
      let m41 = modifierParameters.getCGFloat(12),
      let m42 = modifierParameters.getCGFloat(13),
      let m43 = modifierParameters.getCGFloat(14),
      let m44 = modifierParameters.getCGFloat(15){
      self.m11 = m11
      self.m12 = m12
      self.m13 = m13
      self.m14 = m14
      self.m21 = m21
      self.m22 = m22
      self.m23 = m23
      self.m24 = m24
      self.m31 = m31
      self.m32 = m32
      self.m33 = m33
      self.m34 = m34
      self.m41 = m41
      self.m42 = m42
      self.m43 = m43
      self.m44 = m44
    } else {
      return nil
    }
  }
}
