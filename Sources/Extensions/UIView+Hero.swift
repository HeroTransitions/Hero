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

#if canImport(UIKit)

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

extension UIView: HeroCompatible { }
public extension HeroExtension where Base: UIView {

  /**
   **ID** is the identifier for the view. When doing a transition between two view controllers,
   Hero will search through all the subviews for both view controllers and matches views with the same **heroID**.
   
   Whenever a pair is discovered,
   Hero will automatically transit the views from source state to the destination state.
   */
   var id: String? {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.heroID) as? String }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **isEnabled** allows to specify whether a view and its subviews should be consider for animations.
   If true, Hero will search through all the subviews for heroIds and modifiers. Defaults to true
   */
  var isEnabled: Bool {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.heroEnabled) as? Bool ?? true }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **isEnabledForSubviews** allows to specify whether a view's subviews should be consider for animations.
   If true, Hero will search through all the subviews for heroIds and modifiers. Defaults to true
   */
  var isEnabledForSubviews: Bool {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.heroEnabledForSubviews) as? Bool ?? true }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroEnabledForSubviews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   Use **modifiers** to specify animations alongside the main transition. Checkout `HeroModifier.swift` for available modifiers.
   */
  var modifiers: [HeroModifier]? {
    get { return objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.heroModifiers) as? [HeroModifier] }
    set { objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  /**
   **modifierString** provides another way to set **modifiers**. It can be assigned through storyboard.
   */
  var modifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set { modifiers = newValue?.parse() }
  }

  /// Used for .overFullScreen presentation
  internal var storedAlpha: CGFloat? {
    get {
      if let doubleValue = (objc_getAssociatedObject(base, &type(of: base).AssociatedKeys.heroStoredAlpha) as? NSNumber)?.doubleValue {
        return CGFloat(doubleValue)
      }
      return nil
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroStoredAlpha, NSNumber(value: newValue.native), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      } else {
        objc_setAssociatedObject(base, &type(of: base).AssociatedKeys.heroStoredAlpha, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
}

public extension UIView {
  fileprivate struct AssociatedKeys {
    static var heroID    = "heroID"
    static var heroModifiers = "heroModifers"
    static var heroStoredAlpha = "heroStoredAlpha"
    static var heroEnabled = "heroEnabled"
    static var heroEnabledForSubviews = "heroEnabledForSubviews"
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "hero.id")
  @IBInspectable var heroID: String? {
    get { return hero.id }
    set { hero.id = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "hero.isEnabled")
  @IBInspectable var isHeroEnabled: Bool {
    get { return hero.isEnabled }
    set { hero.isEnabled = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "hero.isEnabledForSubviews")
  @IBInspectable var isHeroEnabledForSubviews: Bool {
    get { return hero.isEnabledForSubviews }
    set { hero.isEnabledForSubviews = newValue }
  }

  @available(*, renamed: "hero.modifiers")
  var heroModifiers: [HeroModifier]? {
    get { return hero.modifiers }
    set { hero.modifiers = newValue }
  }

  // TODO: can be moved to internal later (will still be accessible via IB)
  @available(*, renamed: "hero.modifierString")
  @IBInspectable var heroModifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set { hero.modifiers = newValue?.parse() }
  }

  internal func slowSnapshotView() -> UIView {
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    guard let currentContext = UIGraphicsGetCurrentContext() else {
      UIGraphicsEndImageContext()
      return UIView()
    }
    layer.render(in: currentContext)

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
    guard hero.isEnabled else { return [] }
    if #available(iOS 9.0, *), isHidden && (superview is UICollectionView || superview is UIStackView || self is UITableViewCell) {
      return []
    } else if isHidden && (superview is UICollectionView || self is UITableViewCell) {
      return []
    } else if hero.isEnabledForSubviews {
      return [self] + subviews.flatMap { $0.flattenedViewHierarchy }
    } else {
      return [self]
    }
  }

  @available(*, renamed: "hero.storedAplha")
  internal var heroStoredAlpha: CGFloat? {
    get { return hero.storedAlpha }
    set { hero.storedAlpha = newValue }
  }
}

#endif
