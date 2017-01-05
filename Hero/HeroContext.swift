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

public typealias HeroModifiers = [(String, [String])]

public class HeroContext {
  fileprivate static let parameterRegex = "(?:\\-?\\d+(\\.?\\d+)?)|\\w+"
  fileprivate static let modifiersRegex = "(\\w+)(?:\\(([^\\)]*)\\))?"

  fileprivate var heroIDToSourceView = [String:UIView]()
  fileprivate var heroIDToDestinationView = [String:UIView]()
  fileprivate var snapshotViews = [UIView:UIView]()
  fileprivate var modifiers = [UIView:HeroModifiers]()
  
  internal init(container:UIView, fromView:UIView, toView:UIView){
    fromViews = HeroContext.processViewTree(view: fromView, container: container, idMap: &heroIDToSourceView, modifierMap: &modifiers)
    toViews = HeroContext.processViewTree(view: toView, container: container, idMap: &heroIDToDestinationView, modifierMap: &modifiers)
    self.container = container
  }

  /**
   The container holding all of the animating views
   */
  public let container:UIView

  /**
   A flattened list of all views from source ViewController
   */
  public let fromViews:[UIView]

  /**
   A flattened list of all views from destination ViewController
   */
  public let toViews:[UIView]
}

// public
extension HeroContext{

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
  public func pairedView(for view:UIView) -> UIView?{
    if let id = view.heroID{
      if sourceView(for: id) == view{
        return destinationView(for: id)
      } else if destinationView(for: id) == view{
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

    view.isHidden = false
    
    // capture a snapshot without cornerRadius
    let oldCornerRadius = view.layer.cornerRadius
    view.layer.cornerRadius = 0
    let snapshot:UIView
    if let imageView = view as? UIImageView{
      let contentView = UIImageView(image: imageView.image)
      contentView.frame = imageView.bounds
      contentView.contentMode = imageView.contentMode
      let snapShotView = UIView()
      snapShotView.addSubview(contentView)
      snapshot = snapShotView
    } else {
      snapshot = view.snapshotView(afterScreenUpdates: true)!
    }
    view.layer.cornerRadius = oldCornerRadius
    
    // the Snapshot's contentView must have hold the cornerRadius value,
    // since the snapshot might not have maskToBounds set
    let contentView = snapshot.subviews[0]
    contentView.layer.cornerRadius = view.layer.cornerRadius
    contentView.layer.masksToBounds = true
    
    snapshot.layer.cornerRadius = view.layer.cornerRadius
    if let zPos = self[view, "zPosition"]?.getCGFloat(0){
      snapshot.layer.zPosition = zPos
    } else {
      snapshot.layer.zPosition = view.layer.zPosition
    }

    snapshot.layer.opacity = view.layer.opacity
    snapshot.layer.isOpaque = view.layer.isOpaque
    snapshot.layer.anchorPoint = view.layer.anchorPoint
    snapshot.layer.masksToBounds = view.layer.masksToBounds
    snapshot.layer.borderColor = view.layer.borderColor
    snapshot.layer.borderWidth = view.layer.borderWidth
    snapshot.layer.transform = view.layer.transform
    snapshot.layer.shadowRadius = view.layer.shadowRadius
    snapshot.layer.shadowOpacity = view.layer.shadowOpacity
    snapshot.layer.shadowColor = view.layer.shadowColor
    snapshot.layer.shadowOffset = view.layer.shadowOffset
    
    snapshot.frame = container.convert(view.bounds, from: view)
    snapshot.heroID = view.heroID
    
    view.isHidden = true
    
    container.addSubview(snapshot)
    snapshotViews[view] = snapshot
    return snapshot
  }
  
  /**
   - Returns: a list of all the modifier names for a given view
   */
  public func modifierNames(for view:UIView) -> [String]?{
    return modifiers[view]?.map{ return $0.0 }
  }

  /**
   - Returns: a list of all the modifiers for a given view
   */
  public subscript(view: UIView) -> HeroModifiers? {
    get {
      return modifiers[view]
    }
    set(newValue) {
      modifiers[view] = newValue
    }
  }

  /**
   - Returns: a list of all the modifiers for a given view
   */
  public subscript(view: UIView) -> String {
    get {
      return modifiers[view]?.map{ return "\($0.0)(\($0.1.joined(separator:", ")))" }.joined(separator:" ") ?? ""
    }
    set(newValue) {
      modifiers[view] = HeroContext.extractModifiers(modifierString: newValue)
    }
  }
  
  /**
   - Returns: a list of all the parameters for a given view, and modifierName
   */
  public subscript(view: UIView, modifierName:String) -> [String]? {
    get {
      guard modifiers[view] != nil else { return nil }
      for o in modifiers[view]!.reversed(){
        if o.0 == modifierName{
          return o.1
        }
      }
      return nil
    }
    set(newValue) {
      if let newValue = newValue{
        if self.modifiers[view] == nil{
          self.modifiers[view] = HeroModifiers()
        }
        for (i, o) in modifiers[view]!.enumerated(){
          if o.0 == modifierName{
            self.modifiers[view]![i] = (modifierName, newValue)
            return
          }
        }
        modifiers[view]!.append((modifierName, newValue))
      } else {
        guard modifiers[view] != nil else { return }
        for (i, o) in modifiers[view]!.enumerated(){
          if o.0 == modifierName{
            modifiers[view]!.remove(at: i)
            return
          }
        }
      }
    }
  }
}

// internal
extension HeroContext{
  internal static func extractModifiers(modifierString:String) -> HeroModifiers {
    func matches(for regex: String, text:NSString) -> [NSTextCheckingResult] {
      do {
        let regex = try NSRegularExpression(pattern: regex)
        return regex.matches(in: text as String, range: NSRange(location: 0, length: text.length))
      } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
      }
    }
    var rtn = HeroModifiers()
    let nsString = modifierString as NSString
    for r in matches(for: HeroContext.modifiersRegex, text:nsString){
      var rangeStr = [String]()
      if r.numberOfRanges > 2, r.rangeAt(2).location < nsString.length{
        let parameterString = nsString.substring(with: r.rangeAt(2)) as NSString
        for r in matches(for: HeroContext.parameterRegex, text: parameterString){
          rangeStr.append(parameterString.substring(with: r.range))
        }
      }
      rtn.append((nsString.substring(with: r.rangeAt(1)), rangeStr))
    }
    return rtn
  }
  
  internal static func processViewTree(view:UIView, container:UIView, idMap:inout [String:UIView], modifierMap:inout [UIView:HeroModifiers]) -> [UIView]{
    var rtn:[UIView]
    if container.convert(view.bounds, from: view).intersects(container.bounds){
      rtn = [view]
      if let heroID = view.heroID{
        idMap[heroID] = view
      }
      if let className = view.heroModifiers{
        modifierMap[view] = extractModifiers(modifierString: className)
      }
    } else {
      rtn = []
    }
    for sv in view.subviews{
      rtn.append(contentsOf: processViewTree(view: sv, container:container, idMap:&idMap, modifierMap:&modifierMap))
    }
    return rtn
  }
}
