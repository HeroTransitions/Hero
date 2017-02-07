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

public class HeroContext {
  internal var heroIDToSourceView = [String: UIView]()
  internal var heroIDToDestinationView = [String: UIView]()
  internal var snapshotViews = [UIView: UIView]()
  internal var viewAlphas = [UIView: CGFloat]()
  internal var targetStates = [UIView: HeroTargetState]()

  internal init(container: UIView) {
    self.container = container
  }

  internal func set(fromView:UIView, toView:UIView) {
    fromViews = HeroContext.processViewTree(view: fromView, container: container, idMap: &heroIDToSourceView, stateMap: &targetStates)
    toViews = HeroContext.processViewTree(view: toView, container: container, idMap: &heroIDToDestinationView, stateMap: &targetStates)
  }

  /**
   The container holding all of the animating views
   */
  public let container: UIView

  /**
   A flattened list of all views from source ViewController
   */
  public var fromViews: [UIView]!

  /**
   A flattened list of all views from destination ViewController
   */
  public var toViews: [UIView]!
}

// public
extension HeroContext {

  /**
   - Returns: a source view matching the heroID, nil if not found
   */
  public func sourceView(for heroID: String) -> UIView? {
    return heroIDToSourceView[heroID]
  }

  /**
   - Returns: a destination view matching the heroID, nil if not found
   */
  public func destinationView(for heroID: String) -> UIView? {
    return heroIDToDestinationView[heroID]
  }

  /**
   - Returns: a view with the same heroID, but on different view controller, nil if not found
   */
  public func pairedView(for view: UIView) -> UIView? {
    if let id = view.heroID {
      if sourceView(for: id) == view {
        return destinationView(for: id)
      } else if destinationView(for: id) == view {
        return sourceView(for: id)
      }
    }
    return nil
  }

  /**
   - Returns: a snapshot view for animation
   */
  public func snapshotView(for view: UIView) -> UIView {
    if let snapshot = snapshotViews[view] {
      return snapshot
    }
    
    var containerView = container
    if targetStates[view]?.useGlobalCoordinateSpace != true {
      containerView = view
      while containerView != container, snapshotViews[containerView] == nil, let superview = containerView.superview {
        containerView = superview
      }
      if let snapshot = snapshotViews[containerView] {
        containerView = snapshot
      }
    }
 
    unhide(view: view)

    // capture a snapshot without alpha & cornerRadius
    let oldCornerRadius = view.layer.cornerRadius
    let oldAlpha = view.alpha
    view.layer.cornerRadius = 0
    view.alpha = 1

    let snapshot: UIView
    let snapshotType:HeroSnapshotType = self[view]?.snapshotType ?? .optimized
    
    switch snapshotType {
    case .normal:
      snapshot = view.snapshotView(afterScreenUpdates: true)!
    case .layerRender:
      snapshot = view.slowSnapshotView()
    case .noSnapshot:
      snapshot = view
    case .optimized:
      if #available(iOS 9.0, *), let stackView = view as? UIStackView {
        snapshot = stackView.slowSnapshotView()
      } else if let imageView = view as? UIImageView, view.subviews.isEmpty {
        let contentView = UIImageView(image: imageView.image)
        contentView.frame = imageView.bounds
        contentView.contentMode = imageView.contentMode
        contentView.tintColor = imageView.tintColor
        contentView.backgroundColor = imageView.backgroundColor
        let snapShotView = UIView()
        snapShotView.addSubview(contentView)
        snapshot = snapShotView
      } else if let barView = view as? UINavigationBar, barView.isTranslucent {
        let newBarView = UINavigationBar(frame: barView.frame)
        
        newBarView.barStyle = barView.barStyle
        newBarView.tintColor = barView.tintColor
        newBarView.barTintColor = barView.barTintColor
        newBarView.clipsToBounds = false
        
        // take a snapshot without the background
        barView.layer.sublayers![0].opacity = 0
        let realSnapshot = barView.snapshotView(afterScreenUpdates: true)!
        barView.layer.sublayers![0].opacity = 1
        
        newBarView.addSubview(realSnapshot)
        snapshot = newBarView
      } else {
        snapshot = view.snapshotView(afterScreenUpdates: true)!
      }
    }

    if snapshotType != .noSnapshot {
      snapshot.layer.allowsGroupOpacity = false
    }
    
    view.layer.cornerRadius = oldCornerRadius
    view.alpha = oldAlpha

    if !(view is UINavigationBar), let contentView = snapshot.subviews.get(0) {
      // the Snapshot's contentView must have hold the cornerRadius value,
      // since the snapshot might not have maskToBounds set
      contentView.layer.cornerRadius = view.layer.cornerRadius
      contentView.layer.masksToBounds = true
    }

    snapshot.layer.cornerRadius = view.layer.cornerRadius
    snapshot.layer.zPosition = view.layer.zPosition
    snapshot.layer.opacity = view.layer.opacity
    snapshot.layer.isOpaque = view.layer.isOpaque
    snapshot.layer.anchorPoint = view.layer.anchorPoint
    snapshot.layer.masksToBounds = view.layer.masksToBounds
    snapshot.layer.borderColor = view.layer.borderColor
    snapshot.layer.borderWidth = view.layer.borderWidth
    snapshot.layer.transform = view.layer.transform

    if self[view]?.displayShadow ?? true {
      snapshot.layer.shadowRadius = view.layer.shadowRadius
      snapshot.layer.shadowOpacity = view.layer.shadowOpacity
      snapshot.layer.shadowColor = view.layer.shadowColor
      snapshot.layer.shadowOffset = view.layer.shadowOffset
      snapshot.layer.shadowPath = view.layer.shadowPath
    }

    snapshot.frame = containerView.convert(view.bounds, from: view)
    snapshot.heroID = view.heroID

    hide(view: view)

    if let pairedView = pairedView(for: view), let pairdSnapshot = snapshotViews[pairedView] {
      containerView.addSubview(pairdSnapshot)
    }
    containerView.addSubview(snapshot)
    snapshotViews[view] = snapshot
    return snapshot
  }

  public subscript(view: UIView) -> HeroTargetState? {
    get {
      return targetStates[view]
    }
    set {
      targetStates[view] = newValue
    }
  }
}

// internal
extension HeroContext {
  public func hide(view: UIView) {
    if viewAlphas[view] == nil, self[view]?.snapshotType != .noSnapshot {
      viewAlphas[view] = view.isOpaque ? .infinity : view.alpha
      view.alpha = 0
    }
  }
  public func unhide(view: UIView) {
    if let oldAlpha = viewAlphas[view] {
      if oldAlpha == .infinity {
        view.alpha = 1
        view.isOpaque = true
      } else {
        view.alpha = oldAlpha
      }
      viewAlphas[view] = nil
    }
  }
  internal func unhideAll() {
    for view in viewAlphas.keys {
      unhide(view: view)
    }
    viewAlphas.removeAll()
  }

  internal static func processViewTree(view: UIView, container: UIView, idMap: inout [String: UIView], stateMap: inout [UIView: HeroTargetState]) -> [UIView] {
    var rtn: [UIView]
    if container.convert(view.bounds, from: view).intersects(container.bounds) {
      rtn = [view]
      if let heroID = view.heroID {
        idMap[heroID] = view
      }
      if let modifiers = view.heroModifiers {
        stateMap[view] = HeroTargetState(modifiers: modifiers)
      }
    } else {
      rtn = []
    }
    for sv in view.subviews {
      rtn.append(contentsOf: processViewTree(view: sv, container:container, idMap:&idMap, stateMap:&stateMap))
    }
    return rtn
  }
}
