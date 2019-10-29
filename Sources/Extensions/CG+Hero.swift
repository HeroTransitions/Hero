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

import QuartzCore

let π = CGFloat.pi

internal struct KeySet<Key: Hashable, Value: Hashable> {
  var dict: [Key: Set<Value>] = [:]
  internal subscript(key: Key) -> Set<Value> {
    mutating get {
      if dict[key] == nil {
        dict[key] = Set<Value>()
      }
      return dict[key]!
    }
    set {
      dict[key] = newValue
    }
  }
}

internal extension CGSize {
  var center: CGPoint {
    return CGPoint(x: width / 2, y: height / 2)
  }
  var point: CGPoint {
    return CGPoint(x: width, y: height)
  }
  func transform(_ t: CGAffineTransform) -> CGSize {
    return self.applying(t)
  }
  func transform(_ t: CATransform3D) -> CGSize {
    return self.applying(CATransform3DGetAffineTransform(t))
  }
}

internal extension CGRect {
  var center: CGPoint {
    return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
  }
  var bounds: CGRect {
    return CGRect(origin: CGPoint.zero, size: size)
  }
  init(center: CGPoint, size: CGSize) {
    self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
  }
}

internal extension CGFloat {
  func clamp(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
    return self < a ? a : (self > b ? b : self)
  }
}

internal extension TimeInterval {
  func clamp(_ a: TimeInterval, _ b: TimeInterval) -> TimeInterval {
    return self < a ? a : (self > b ? b : self)
  }
}

internal extension CGPoint {
  func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
    return CGPoint(x: self.x + dx, y: self.y + dy)
  }

  func transform(_ t: CGAffineTransform) -> CGPoint {
    return self.applying(t)
  }

  func transform(_ t: CATransform3D) -> CGPoint {
    return self.applying(CATransform3DGetAffineTransform(t))
  }

  func distance(_ b: CGPoint) -> CGFloat {
    return sqrt(pow(self.x - b.x, 2) + pow(self.y - b.y, 2))
  }

  static func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
  }

  static func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
  }

  static func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
  }
  static func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
  }
  static func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
  }
  static func * (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x * right.width, y: left.y * right.height)
  }
  static func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return right * left
  }

  static func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
  }

  static prefix func - (point: CGPoint) -> CGPoint {
    return .zero - point
  }

  static func abs(_ p: CGPoint) -> CGPoint {
    return CGPoint(x: Swift.abs(p.x), y: Swift.abs(p.y))
  }
}

internal extension CGSize {
  static func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
  }
  static func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
  }
  static func / (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
  }
  static func / (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x / right.width, y: left.y / right.height)
  }
}

extension CATransform3D: Equatable {
  public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
    var lhs = lhs
    var rhs = rhs
    return memcmp(&lhs, &rhs, MemoryLayout<CATransform3D>.size) == 0
  }
}
