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

private let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
  let originalMethod = class_getInstanceMethod(forClass, originalSelector)
  let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
  method_exchangeImplementations(originalMethod, swizzledMethod)
}

var addedAnimations: [(CALayer, String, CAAnimation)]?
extension CALayer {
  open override class func initialize() {
    // make sure this isn't a subclass
    guard self === CALayer.self else { return }

    let originalSelector = #selector(add(_:forKey:))
    let swizzledSelector = #selector(hero_add(anim:forKey:))
    swizzling(self, originalSelector, swizzledSelector)
  }
  func swizzled_layoutSubviews() {
    swizzled_layoutSubviews()
    print("swizzled_layoutSubviews")
  }
  dynamic func hero_add(anim: CAAnimation, forKey: String?) {
    addedAnimations?.append((self, forKey!, anim))
    hero_add(anim: anim, forKey: forKey)
  }
}

internal class HeroViewAnimationRunner: HeroAnimatorViewContext {

  var state = [String: (Any?, Any?)]()
  var timingFunction: CAMediaTimingFunction = .standard
  var animations: [(CALayer, String, CAAnimation)] = []

  override class func canAnimate(view: UIView, state: HeroTargetState, appearing: Bool) -> Bool {
    return state.position != nil ||
           state.size != nil ||
           state.transform != nil ||
           state.cornerRadius != nil ||
           state.opacity != nil ||
           state.overlay != nil ||
           state.backgroundColor != nil ||
           state.borderColor != nil ||
           state.borderWidth != nil ||
           state.shadowOpacity != nil ||
           state.shadowRadius != nil ||
           state.shadowOffset != nil ||
           state.shadowColor != nil ||
           state.shadowPath != nil ||
           state.contentsRect != nil ||
           state.forceAnimate
  }

  func currentValue(key: String) -> Any? {
    if snapshot.layer.animationKeys()?.isEmpty != false {
      return snapshot.layer.value(forKeyPath:key)
    }
    return (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)
  }

  func set(view: UIView, key: String, value: Any?) {
    if key == "bounds.size" {
      let newSize = (value as! NSValue).cgSizeValue
      let oldSize = view.bounds.size
      for subview in view.subviews {
        let center = subview.layer.position
        let size = subview.bounds.size
        subview.layer.position = CGPoint(x: center.x / oldSize.width * newSize.width, y: center.y / oldSize.height * newSize.height)
        set(view: subview, key: key, value: NSValue(cgSize: size / oldSize * newSize))
      }
      view.bounds.size = newSize
    } else {
      view.layer.setValue(value, forKeyPath: key)
    }
  }

  func animate(key: String, duration: TimeInterval, delay: TimeInterval, fromValue: Any?, toValue: Any?) {
    if key == "position", let arcIntensity = targetState.arc,
      let fromPos = (fromValue as? NSValue)?.cgPointValue,
      let toPos = (toValue as? NSValue)?.cgPointValue,
      abs(fromPos.x - toPos.x) >= 1, abs(fromPos.y - toPos.y) >= 1 {
      let anim = CAKeyframeAnimation(keyPath: key)

      let path = CGMutablePath()
      let maxControl = fromPos.y > toPos.y ? CGPoint(x: toPos.x, y: fromPos.y) : CGPoint(x: fromPos.x, y: toPos.y)
      let minControl = (toPos - fromPos) / 2 + fromPos

      path.move(to: fromPos)
      path.addQuadCurve(to: toPos, control: minControl + (maxControl - minControl) * arcIntensity)

      anim.values = [fromValue!, toValue!]
      anim.path = path
      anim.duration = duration
      anim.timingFunctions = [timingFunction]
      anim.fillMode = kCAFillModeBoth
      anim.isRemovedOnCompletion = false
      anim.beginTime = delay
      // anim.setValue("absolute", forKey: "beginTimeMode")
      snapshot.layer.add(anim, forKey: "position")
    } else {
      set(view: snapshot, key: key, value: fromValue)
      CATransaction.begin()
      if let (stiffness, damping) = targetState.spring {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping / 100, initialSpringVelocity: 0, options: [], animations: {
          self.set(view: self.snapshot, key: key, value: toValue)
        }, completion: nil)
      } else {
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
          self.set(view: self.snapshot, key: key, value: toValue)
        }, completion: nil)
      }
      CATransaction.commit()
    }
  }

  /**
   - Returns: a CALayer [keyPath:value] map for animation
   */
  func viewState(targetState: HeroTargetState) -> [String: Any?] {
    var targetState = targetState
    var rtn = [String: Any?]()

    if let size = targetState.size {
      if targetState.useScaleBasedSizeChange ?? self.targetState.useScaleBasedSizeChange ?? false {
        let currentSize = snapshot.bounds.size
        targetState.append(.scale(x:size.width / currentSize.width,
                                  y:size.height / currentSize.height))
      } else {
        rtn["bounds.size"] = NSValue(cgSize:size)
      }
    }
    if let position = targetState.position {
      rtn["position"] = NSValue(cgPoint:position)
    }
    if let opacity = targetState.opacity, !(snapshot is UIVisualEffectView) {
      rtn["opacity"] = NSNumber(value: opacity)
    }
    if let cornerRadius = targetState.cornerRadius {
      rtn["cornerRadius"] = NSNumber(value: cornerRadius.native)
    }
    if let backgroundColor = targetState.backgroundColor {
      rtn["backgroundColor"] = backgroundColor
    }
    if let zPosition = targetState.zPosition {
      rtn["zPosition"] = NSNumber(value: zPosition.native)
    }

    if let borderWidth = targetState.borderWidth {
      rtn["borderWidth"] = NSNumber(value: borderWidth.native)
    }
    if let borderColor = targetState.borderColor {
      rtn["borderColor"] = borderColor
    }
    if let masksToBounds = targetState.masksToBounds {
      rtn["masksToBounds"] = masksToBounds
    }

    if targetState.displayShadow {
      if let shadowColor = targetState.shadowColor {
        rtn["shadowColor"] = shadowColor
      }
      if let shadowRadius = targetState.shadowRadius {
        rtn["shadowRadius"] = NSNumber(value: shadowRadius.native)
      }
      if let shadowOpacity = targetState.shadowOpacity {
        rtn["shadowOpacity"] = NSNumber(value: shadowOpacity)
      }
      if let shadowPath = targetState.shadowPath {
        rtn["shadowPath"] = shadowPath
      }
      if let shadowOffset = targetState.shadowOffset {
        rtn["shadowOffset"] = NSValue(cgSize: shadowOffset)
      }
    }

    if let contentsRect = targetState.contentsRect {
      rtn["contentsRect"] = NSValue(cgRect: contentsRect)
    }

    if let contentsScale = targetState.contentsScale {
      rtn["contentsScale"] = NSNumber(value: contentsScale.native)
    }

    if let transform = targetState.transform {
      rtn["transform"] = NSValue(caTransform3D: transform)
    }

    if let (color, opacity) = targetState.overlay {
      rtn["overlay.backgroundColor"] = color
      rtn["overlay.opacity"] = NSNumber(value: opacity.native)
    }
    return rtn
  }

  override func apply(state: HeroTargetState) {
    let targetState = viewState(targetState: state)
    for (key, targetValue) in targetState {
      if self.state[key] == nil {
        let current = currentValue(key: key)
        self.state[key] = (current, current)
      }
      animate(key: key, duration: 100, delay: 0, fromValue: targetValue, toValue: targetValue)
    }
  }

  override func resume(timePassed: TimeInterval, reverse: Bool) {
    for (layer, key, anim) in animations {
      layer.removeAnimation(forKey: key)
    }
    for (key, (fromValue, toValue)) in state {
      let realToValue = !reverse ? toValue : fromValue
      let realFromValue = currentValue(key: key)
      state[key] = (realFromValue, realToValue)
    }

    // we need to update the duration to reflect current state
    targetState.duration = reverse ? timePassed - targetState.delay : duration - timePassed

    let realDelay = max(0, targetState.delay - timePassed)
    animate(delay: realDelay)
  }

  func animate(delay: TimeInterval) {
    if let tf = targetState.timingFunction {
      timingFunction = tf
    }

    addedAnimations = []
    for (key, (fromValue, toValue)) in state {
      animate(key: key, duration:targetState.duration!, delay: delay, fromValue: fromValue, toValue: toValue)
    }
    animations = addedAnimations!
    addedAnimations = nil

    duration = targetState.duration! + targetState.delay
  }

  override func seek(timePassed: TimeInterval) {
    for (layer, key, anim) in animations {
      anim.speed = 0
      anim.timeOffset = (timePassed - targetState.delay).clamp(0, anim.duration - 0.01)
      layer.removeAnimation(forKey: key)
      layer.add(anim, forKey: key)
    }
  }

  /*
  override func seek(timePassed: TimeInterval) {
    snapshot.layer.speed = 0
    snapshot.layer.timeOffset = (timePassed - targetState.delay).clamp(0, targetState.duration!)
   }
   */

  override func startAnimations(appearing: Bool) {
    if let beginState = targetState.beginState?.state {
      let appeared = viewState(targetState: beginState)
      for (key, value) in appeared {
        snapshot.layer.setValue(value, forKeyPath: key)
      }
    }

    let disappeared = viewState(targetState: targetState)

    for (key, disappearedState) in disappeared {
      let appearingState = currentValue(key: key)
      let toValue = appearing ? appearingState : disappearedState
      let fromValue = !appearing ? appearingState : disappearedState
      state[key] = (fromValue, toValue)
    }

    animate(delay: targetState.delay)
  }
}
