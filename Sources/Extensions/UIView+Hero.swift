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

class SnapshotWrapperView: UIView {
  let contentView: UIView
  init(contentView: UIView) {
    self.contentView = contentView
    super.init(frame: contentView.frame)
    addSubview(contentView)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.bounds.size = bounds.size
    contentView.center = bounds.center
  }
}

public extension UIView {
  private struct AssociatedKeys {
    static var heroID    = "heroID"
    static var heroModifiers = "heroModifers"
    static var heroStoredAlpha = "heroStoredAlpha"
    static var heroEnabled = "heroEnabled"
    static var heroEnabledForSubviews = "heroEnabledForSubviews"
  }

  /**
   **heroID** is the identifier for the view. When doing a transition between two view controllers,
   Hero will search through all the subviews for both view controllers and matches views with the same **heroID**.

   Whenever a pair is discovered,
   Hero will automatically transit the views from source state to the destination state.
   */
  @IBInspectable public var heroID: String? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.heroID) as? String }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **isHeroEnabled** allows to specify whether a view and its subviews should be consider for animations.
   If true, Hero will search through all the subviews for heroIds and modifiers. Defaults to true
   */
  @IBInspectable public var isHeroEnabled: Bool {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.heroEnabled) as? Bool ?? true }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **isHeroEnabledForSubviews** allows to specify whether a view's subviews should be consider for animations.
   If true, Hero will search through all the subviews for heroIds and modifiers. Defaults to true
   */
  @IBInspectable public var isHeroEnabledForSubviews: Bool {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.heroEnabledForSubviews) as? Bool ?? true }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroEnabledForSubviews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   Use **heroModifiers** to specify animations alongside the main transition. Checkout `HeroModifier.swift` for available modifiers.
   */
  public var heroModifiers: [HeroModifier]? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.heroModifiers) as? [HeroModifier] }
    set { objc_setAssociatedObject(self, &AssociatedKeys.heroModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **heroModifierString** provides another way to set **heroModifiers**. It can be assigned through storyboard.
   */
  @IBInspectable public var heroModifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set { heroModifiers = newValue?.parse() }
  }

  internal func slowSnapshotView() -> UIView {
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    layer.render(in: UIGraphicsGetCurrentContext()!)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let imageView = UIImageView(image: image)
    imageView.frame = bounds
    return SnapshotWrapperView(contentView: imageView)
  }

  internal func snapshotView() -> UIView? {
    let snapshot = snapshotView(afterScreenUpdates: true)
    if #available(iOS 11.0, *), let oldSnapshot = snapshot {
      // in iOS 11, the snapshot taken by snapshotView(afterScreenUpdates) won't contain a container view
      return SnapshotWrapperView(contentView: oldSnapshot)
    } else {
      return snapshot
    }
  }

  internal var flattenedViewHierarchy: [UIView] {
    guard isHeroEnabled else { return [] }
    if #available(iOS 9.0, *), isHidden && (superview is UICollectionView || superview is UIStackView || self is UITableViewCell) {
      return []
    } else if isHidden && (superview is UICollectionView || self is UITableViewCell) {
      return []
    } else if isHeroEnabledForSubviews {
      return [self] + subviews.flatMap { $0.flattenedViewHierarchy }
    } else {
      return [self]
    }
  }

  /// Used for .overFullScreen presentation
  internal var heroStoredAlpha: CGFloat? {
    get {
      if let doubleValue = (objc_getAssociatedObject(self, &AssociatedKeys.heroStoredAlpha) as? NSNumber)?.doubleValue {
        return CGFloat(doubleValue)
      }
      return nil
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &AssociatedKeys.heroStoredAlpha, NSNumber(value: newValue.native), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(self, &AssociatedKeys.heroStoredAlpha, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}
