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

public struct HeroTargetState {
  internal var opacity:CGFloat?
  internal var cornerRadius:CGFloat?
  internal var position:CGPoint?
  internal var size:CGSize?
  internal var transform:CATransform3D?
  internal var spring:(CGFloat, CGFloat)?
  internal var delay:TimeInterval = 0
  internal var duration:TimeInterval?
  internal var timingFunction:CAMediaTimingFunction?
  internal var arc:CGFloat?
  internal var zPosition:CGFloat?
  internal var zPositionIfMatched:CGFloat?
  internal var source:String?
  internal var cascade:(TimeInterval, CascadePreprocessor.CascadeDirection, Bool)?
  internal var ignoreSubviewModifiers = false

  internal var custom:[String:Any]?
  
  init(modifiers:[HeroModifier]) {
    append(contentsOf: modifiers)
  }
  
  mutating func append(contentsOf modifiers:[HeroModifier]){
    var transform = self.transform ?? CATransform3DIdentity
    for modifier in modifiers {
      switch modifier{
      case .fade:
        self.opacity = 0
      case .position(let position):
        self.position = position
      case .size(let size):
        self.size = size
      case .perspective(let perspective):
        transform.m34 = 1.0 / -perspective
      case .transform(let t):
        transform = t
      case .scale(let x, let y):
        transform = CATransform3DScale(transform, x, y, 1)
      case .rotate(let x, let y, let z):
        transform = CATransform3DRotate(transform, x, 1, 0, 0)
        transform = CATransform3DRotate(transform, y, 0, 1, 0)
        transform = CATransform3DRotate(transform, z, 0, 0, 1)
      case .translate(let x, let y, let z):
        transform = CATransform3DTranslate(transform, x, y, z)
      case .spring(let stiffness, let damping):
        self.spring = (stiffness, damping)
      case .zPosition(let zPosition):
        self.zPosition = zPosition
      case .zPositionIfMatched(let zPositionIfMatched):
        self.zPositionIfMatched = zPositionIfMatched
      case .duration(let duration):
        self.duration = duration
      case .timingFunction(let timingFunction):
        self.timingFunction = timingFunction
      case .delay(let delay):
        self.delay = delay
      case .arc(let intensity):
        self.arc = intensity
      case .source(let heroID):
        self.source = heroID
      case .cascade(let delta, let direction, let delayMatchedViews):
        self.cascade = (delta, direction, delayMatchedViews)
      case .ignoreSubviewModifiers:
        self.ignoreSubviewModifiers = true
      case .custom(let name, let userInfo):
        if custom == nil {
          custom = [:]
        }
        self.custom![name] = userInfo
      }
    }
    if transform != CATransform3DIdentity{
      self.transform = transform
    }
  }
  
  /**
   - Returns: custom item for a specific key
   */
  public subscript(key: String) -> Any? {
    get {
      return custom?[key]
    }
    set(newValue) {
      if custom == nil {
        custom = [:]
      }
      custom![key] = newValue
    }
  }
}

extension HeroTargetState: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: HeroModifier...) {
    append(contentsOf: elements)
  }
}
