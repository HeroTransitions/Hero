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


public enum HeroSnapshotType {
  /// Will optimize for different type of views
  /// For custom views or views with masking, .optimizedDefault might create snapshots 
  /// that appear differently than the actual view.
  /// In that case, use .normal or .slowRender to disable the optimization
  case optimized
  
  /// snapshotView(afterScreenUpdates:)
  case normal
  
  /// layer.render(in: currentContext)
  case layerRender
  
  /// will not create snapshot. animate the view directly.
  /// This will mess up the view hierarchy, therefore, view controllers have to rebuild
  /// its view structure after the transition finishes
  case noSnapshot
}

public struct HeroTargetState {
  internal var position: CGPoint?
  internal var size: CGSize?
  internal var transform: CATransform3D?
  internal var opacity: Float?
  internal var cornerRadius: CGFloat?
  internal var zPosition: CGFloat?

  internal var borderWidth: CGFloat?
  internal var borderColor: CGColor?

  internal var shadowColor: CGColor?
  internal var shadowOpacity: Float?
  internal var shadowOffset: CGSize?
  internal var shadowRadius: CGFloat?
  internal var shadowPath: CGPath?
  internal var displayShadow: Bool = true

  internal var spring: (CGFloat, CGFloat)?
  internal var delay: TimeInterval = 0
  internal var duration: TimeInterval?
  internal var timingFunction: CAMediaTimingFunction?

  internal var arc: CGFloat?
  internal var source: String?
  internal var cascade: (TimeInterval, CascadeDirection, Bool)?
  
  internal var ignoreSubviewModifiers: Bool?
  internal var useGlobalCoordinateSpace: Bool?
  internal var useScaleBasedSizeChange: Bool?
  internal var snapshotType: HeroSnapshotType?

  internal var custom: [String:Any]?

  init(modifiers: [HeroModifier]) {
    append(contentsOf: modifiers)
  }

  mutating func append(_ modifier: HeroModifier) {
    modifier.apply(&self)
  }

  mutating func append(contentsOf modifiers: [HeroModifier]) {
    for modifier in modifiers {
      modifier.apply(&self)
    }
  }

  /**
   - Returns: custom item for a specific key
   */
  public subscript(key: String) -> Any? {
    get {
      return custom?[key]
    }
    set {
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
