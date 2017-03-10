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

public enum HeroCoordinateSpace {
  case global
  case local
  case sameParent
}

public struct HeroTargetState {
  class HeroTargetStateWrapper {
    var state: HeroTargetState
    init(state: HeroTargetState) {
      self.state = state
    }
  }
  internal var beginState: HeroTargetStateWrapper?
  public var beginStateIfMatched: [HeroModifier]?

  public var position: CGPoint?
  public var size: CGSize?
  public var transform: CATransform3D?
  public var opacity: Float?
  public var cornerRadius: CGFloat?
  public var backgroundColor: CGColor?
  public var zPosition: CGFloat?

  public var contentsRect: CGRect?
  public var contentsScale: CGFloat?

  public var borderWidth: CGFloat?
  public var borderColor: CGColor?

  public var shadowColor: CGColor?
  public var shadowOpacity: Float?
  public var shadowOffset: CGSize?
  public var shadowRadius: CGFloat?
  public var shadowPath: CGPath?
  public var masksToBounds: Bool?
  public var displayShadow: Bool = true

  public var overlay: (color: CGColor, opacity: CGFloat)?

  public var spring: (CGFloat, CGFloat)?
  public var delay: TimeInterval = 0
  public var duration: TimeInterval?
  public var timingFunction: CAMediaTimingFunction?

  public var arc: CGFloat?
  public var source: String?
  public var cascade: (TimeInterval, CascadeDirection, Bool)?

  public var ignoreSubviewModifiers: Bool?
  public var coordinateSpace: HeroCoordinateSpace?
  public var useScaleBasedSizeChange: Bool?
  public var snapshotType: HeroSnapshotType?

  public var nonFade: Bool = false
  public var forceAnimate: Bool = false
  public var custom: [String:Any]?

  init(modifiers: [HeroModifier]) {
    append(contentsOf: modifiers)
  }

  public mutating func append(_ modifier: HeroModifier) {
    modifier.apply(&self)
  }

  public mutating func append(contentsOf modifiers: [HeroModifier]) {
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
