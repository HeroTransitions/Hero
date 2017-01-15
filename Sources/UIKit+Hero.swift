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

fileprivate let parameterRegex = "(?:\\-?\\d+(\\.?\\d+)?)|\\w+"
fileprivate let modifiersRegex = "(\\w+)(?:\\(([^\\)]*)\\))?"

public extension UIView{
  private struct AssociatedKeys {
    static var HeroID    = "ht_heroID"
    static var HeroModifiers = "ht_heroModifers"
  }
  
  @IBInspectable public var heroID: String? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.HeroID) as? String
    }
    
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.HeroID,
        newValue as NSString?,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  public var heroModifiers: [HeroModifier]? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.HeroModifiers) as? [HeroModifier]
    }
    
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.HeroModifiers,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  @IBInspectable public var heroModifierString: String? {
    get { fatalError("Reverse lookup is not supported") }
    set {
      guard let newValue = newValue else {
        heroModifiers = nil
        return
      }
      let modifierString = newValue as NSString
      func matches(for regex: String, text:NSString) -> [NSTextCheckingResult] {
        do {
          let regex = try NSRegularExpression(pattern: regex)
          return regex.matches(in: text as String, range: NSRange(location: 0, length: text.length))
        } catch let error {
          print("invalid regex: \(error.localizedDescription)")
          return []
        }
      }
      var modifiers = [HeroModifier]()
      for r in matches(for: modifiersRegex, text:modifierString){
        var parameters = [String]()
        if r.numberOfRanges > 2, r.rangeAt(2).location < modifierString.length{
          let parameterString = modifierString.substring(with: r.rangeAt(2)) as NSString
          for r in matches(for: parameterRegex, text: parameterString){
            parameters.append(parameterString.substring(with: r.range))
          }
        }
        let name = modifierString.substring(with: r.rangeAt(1))
        if let modifier = HeroModifier.from(name: name, parameters: parameters){
          modifiers.append(modifier)
        }
      }
      heroModifiers = modifiers
    }
  }

  func slowSnapshotView() -> UIView{
    UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
    layer.render(in: UIGraphicsGetCurrentContext()!)
//    drawHierarchy(in: bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let imageView = UIImageView(image: image)
    imageView.frame = bounds
    let snapshotView = UIView(frame:bounds)
    snapshotView.addSubview(imageView)
    return snapshotView
  }
}

internal extension NSObject{
  func copyWithArchiver() -> Any? {
    return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))!
  }
}

public extension UIViewController{
  @IBInspectable public var isHeroEnabled: Bool {
    get {
      return ((transitioningDelegate as? Hero) != nil)
    }
    
    set {
      guard newValue != isHeroEnabled else { return }
      if newValue{
        transitioningDelegate = Hero.shared
        if let navi = self as? UINavigationController{
          navi.delegate = Hero.shared
        }
        if let tab = self as? UITabBarController{
          tab.delegate = Hero.shared
        }
      } else {
        if isHeroEnabled {
          transitioningDelegate = nil
        }
        if let navi = self as? UINavigationController, let _ = navi.delegate as? Hero{
          navi.delegate = nil
        }
        if let tab = self as? UITabBarController, let _ = tab.delegate as? Hero{
          tab.delegate = nil
        }
      }
    }
  }

  @IBAction public func ht_dismiss(_ sender:UIView){
    dismiss(animated: true, completion: nil)
  }
  
  public func heroReplaceViewController(with next:UIViewController){
    if let navigationController = navigationController {
      var vcs = navigationController.childViewControllers
      vcs.removeLast()
      vcs.append(next)
      navigationController.setViewControllers(vcs, animated: true)
    } else {
      let parentVC = presentingViewController
      let container = self.view.superview!
      let oldTransitionDelegate = next.transitioningDelegate
      next.isHeroEnabled = true
      Hero.shared.transition(from: self, to: next, in: container) {
        if (oldTransitionDelegate as? Hero) == nil{
          next.isHeroEnabled = false
          next.transitioningDelegate = oldTransitionDelegate
        }
        
        UIApplication.shared.keyWindow?.addSubview(next.view)
        
        if let parentVC = parentVC {
          self.dismiss(animated: false) {
            parentVC.present(next, animated: false, completion:nil)
          }
        } else {
          UIApplication.shared.keyWindow?.rootViewController = next
        }
      }
    }
  }
}

internal extension UIImage {
  class func imageWithView(view: UIView) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }
}

internal func ==(lhs:CATransform3D, rhs:CATransform3D) -> Bool{
  var lhs = lhs
  var rhs = rhs
  return memcmp(&lhs, &rhs, MemoryLayout<CATransform3D>.size) == 0
}

internal func !=(lhs:CATransform3D, rhs:CATransform3D) -> Bool{
  return !(lhs == rhs)
}
