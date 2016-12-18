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

public extension UIView{
  private struct AssociatedKeys {
    static var HeroID    = "ht_heroID"
    static var HeroModifiers = "ht_heroModifiers"
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
  @IBInspectable public var heroModifiers: String? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.HeroModifiers) as? String
    }
    
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.HeroModifiers,
        newValue as NSString?,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
}

public extension UIViewController{
  private struct AssociatedKeys {
    static var HeroTransition    = "ht_heroTransition"
  }
  private var hero: Hero? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.HeroTransition) as? Hero
    }
    
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.HeroTransition,
        newValue as Hero?,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  @IBInspectable public var isHeroEnabled: Bool {
    get {
      return ((transitioningDelegate as? Hero) != nil)
    }
    
    set {
      guard newValue != isHeroEnabled else { return }
      if newValue{
        hero = Hero()
        transitioningDelegate = hero
        if let navi = self as? UINavigationController{
          navi.delegate = hero
        }
        if let tab = self as? UITabBarController{
          tab.delegate = hero
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
        hero = nil
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
      next.hero!.transition(from: self, to: next, in: container) {
        if (oldTransitionDelegate as? Hero) == nil{
          next.isHeroEnabled = false
          next.transitioningDelegate = oldTransitionDelegate
        }
        
        UIApplication.shared.keyWindow?.addSubview(next.view)

        self.dismiss(animated: false) {
          if let parentVC = parentVC {
            parentVC.present(next, animated: false, completion:nil)
          } else {
            UIApplication.shared.keyWindow?.rootViewController = next
          }
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
  return lhs.m11 == rhs.m11 &&
         lhs.m12 == rhs.m12 &&
         lhs.m13 == rhs.m13 &&
         lhs.m14 == rhs.m14 &&
         lhs.m21 == rhs.m21 &&
         lhs.m22 == rhs.m22 &&
         lhs.m23 == rhs.m23 &&
         lhs.m24 == rhs.m24 &&
         lhs.m31 == rhs.m31 &&
         lhs.m32 == rhs.m32 &&
         lhs.m33 == rhs.m33 &&
         lhs.m34 == rhs.m34 &&
         lhs.m41 == rhs.m41 &&
         lhs.m42 == rhs.m42 &&
         lhs.m43 == rhs.m43 &&
         lhs.m44 == rhs.m44
}

internal func !=(lhs:CATransform3D, rhs:CATransform3D) -> Bool{
  return !(lhs == rhs)
}
