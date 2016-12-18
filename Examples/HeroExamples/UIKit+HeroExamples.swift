//
//  UIKit+HeroTransitionExample.swift
//  HeroTransitionExample
//
//  Created by Luke Zhao on 2016-11-23.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

public extension UIView{
  @IBInspectable public var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    
    set {
      layer.cornerRadius = newValue
    }
  }
  @IBInspectable public var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    
    set {
      layer.shadowRadius = newValue
    }
  }
  @IBInspectable public var shadowOpacity: Float {
    get {
      return layer.shadowOpacity
    }
    
    set {
      layer.shadowOpacity = newValue
    }
  }
  @IBInspectable public var shadowColor: UIColor? {
    get {
      return layer.shadowColor != nil ? UIColor(cgColor: layer.shadowColor!) : nil
    }
    
    set {
      layer.shadowColor = newValue?.cgColor
    }
  }
  @IBInspectable public var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }
    
    set {
      layer.shadowOffset = newValue
    }
  }
  @IBInspectable public var zPosition: CGFloat {
    get {
      return layer.zPosition
    }
    
    set {
      layer.zPosition = newValue
    }
  }
  @IBInspectable public var anchorPoint: CGPoint {
    get {
      return layer.anchorPoint
    }
    
    set {
      var newPoint = CGPoint(x:bounds.size.width * anchorPoint.x, y:bounds.size.height * anchorPoint.y)
      var oldPoint = CGPoint(x:bounds.size.width * layer.anchorPoint.x, y:bounds.size.height * layer.anchorPoint.y)
      
      newPoint = newValue.applying(transform)
      oldPoint = anchorPoint.applying(transform)
      
      var position = layer.position
      position.x -= oldPoint.x
      position.x += newPoint.x
      
      position.y -= oldPoint.y
      position.y += newPoint.y
      
      layer.position = position
      layer.anchorPoint = anchorPoint
    }
  }
}
