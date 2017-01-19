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

internal extension Array {
  func get(_ index: Int) -> Element? {
    if index < count {
      return self[index]
    }
    return nil
  }
  func getCGFloat(_ index: Int) -> CGFloat? {
    if let s = get(index) as? String, let f = Float(s) {
      return CGFloat(f)
    }
    return nil
  }
  func getDouble(_ index: Int) -> Double? {
    if let s = get(index) as? String, let f = Double(s) {
      return f
    }
    return nil
  }
  func getFloat(_ index: Int) -> Float? {
    if let s = get(index) as? String, let f = Float(s) {
      return f
    }
    return nil
  }
  func getBool(_ index: Int) -> Bool? {
    if let s = get(index) as? String, let f = Bool(s) {
      return f
    }
    return nil
  }

  mutating func filterInPlace(_ comparator: (Element) -> Bool) -> [Element] {
    var array2: [Element] = []
    self = self.filter { (element) -> Bool in
      if comparator(element) {
        return true
      } else {
        array2.append(element)
        return false
      }
    }
    return array2
  }
}
