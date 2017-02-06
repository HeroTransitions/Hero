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

internal class HeroDefaultAnimatorViewContext {
  weak var animator: HeroDefaultAnimator?
  var snapshot: UIView
  var state = [String: (Any?, Any?)]()
  var duration: TimeInterval = 0

  var targetState: HeroTargetState
  var defaultTiming: (TimeInterval, CAMediaTimingFunction)!

  // computed
  var contentLayer: CALayer? {
    return snapshot.layer.sublayers?.get(0)
  }
  var currentTime: TimeInterval {
    return snapshot.layer.convertTime(CACurrentMediaTime(), from: nil)
  }
  var container: UIView? {
    return animator?.context.container
  }

  /*
  // return (delay, duration, easing)
  func getTiming(key:String, fromValue:Any?, toValue:Any?) -> (TimeInterval, TimeInterval, CAMediaTimingFunction){
    // delay should be for a specific animation. this shouldn't include the baseDelay

    // TODO: dynamic delay and duration for different key
    // https://material.io/guidelines/motion/choreography.html#choreography-continuity

    switch key {
    case "opacity":
      if let value = (toValue as? NSNumber)?.floatValue{
        switch value {
        case 0.0:
          // disappearing element
          return (0, 0.075, .standard)
        case 1.0:
          // appearing element
          return (0.075, defaultTiming.0 - 0.075, .standard)
        default:
          break
        }
      }
    default:
      break
    }
    return (0.0, defaultTiming.0, defaultTiming.1)
  }
  */

  func getAnimation(key: String, beginTime: TimeInterval, fromValue: Any?, toValue: Any?, ignoreArc: Bool = false) -> CAPropertyAnimation {
    let anim: CAPropertyAnimation

    let (delay, duration, timingFunction) = (0.0, defaultTiming.0, defaultTiming.1)

    if !ignoreArc, key == "position", let arcIntensity = targetState.arc,
      let fromPos = (fromValue as? NSValue)?.cgPointValue,
      let toPos = (toValue as? NSValue)?.cgPointValue,
      abs(fromPos.x - toPos.x) >= 1, abs(fromPos.y - toPos.y) >= 1 {
      let kanim = CAKeyframeAnimation(keyPath: key)

      let path = CGMutablePath()
      let maxControl = fromPos.y > toPos.y ? CGPoint(x: toPos.x, y: fromPos.y) : CGPoint(x: fromPos.x, y: toPos.y)
      let minControl = (toPos - fromPos) / 2 + fromPos

      path.move(to: fromPos)
      path.addQuadCurve(to: toPos, control: minControl + (maxControl - minControl) * arcIntensity)

      kanim.values = [fromValue!, toValue!]
      kanim.path = path
      kanim.duration = duration
      kanim.timingFunctions = [timingFunction]
      anim = kanim
    } else if #available(iOS 9.0, *), key != "cornerRadius", let (stiffness, damping) = targetState.spring {
      let sanim = CASpringAnimation(keyPath: key)
      sanim.stiffness = stiffness
      sanim.damping = damping
      sanim.duration = sanim.settlingDuration * 0.9
      sanim.fromValue = fromValue
      sanim.toValue = toValue
      anim = sanim
    } else {
      let banim = CABasicAnimation(keyPath: key)
      banim.duration = duration
      banim.fromValue = fromValue
      banim.toValue = toValue
      banim.timingFunction = timingFunction
      anim = banim
    }

    anim.fillMode = kCAFillModeBoth
    anim.isRemovedOnCompletion = false
    anim.beginTime = beginTime + delay
    return anim
  }

  // return the completion duration of the animation (duration + initial delay, not counting the beginTime)
  @discardableResult func addAnimation(key: String, beginTime: TimeInterval, fromValue: Any?, toValue: Any?) -> TimeInterval {
    let anim = getAnimation(key: key, beginTime:beginTime, fromValue: fromValue, toValue: toValue)

    snapshot.layer.add(anim, forKey: key)
    if key == "cornerRadius"{
      contentLayer?.add(anim, forKey: key)
      snapshot.layer.add(anim, forKey: key)
    } else if key == "bounds.size"{
      let fromSize = (fromValue as? NSValue)!.cgSizeValue
      let toSize = (toValue as? NSValue)!.cgSizeValue

      // for the snapshotView(UIReplicantView): there is a
      // subview(UIReplicantContentView) that is hosting the real snapshot image.
      // because we are using CAAnimations and not UIView animations,
      // The snapshotView will not layout during animations.
      // we have to add two more animations to manually layout the content view.
      let fromPosn = NSValue(cgPoint:fromSize.center)
      let toPosn = NSValue(cgPoint:toSize.center)

      let positionAnim = getAnimation(key: "position", beginTime:0, fromValue: fromPosn, toValue: toPosn, ignoreArc: true)
      positionAnim.beginTime = anim.beginTime
      positionAnim.timingFunction = anim.timingFunction
      positionAnim.duration = anim.duration

      contentLayer?.add(positionAnim, forKey: "position")
      contentLayer?.add(anim, forKey: key)
    }

    return anim.duration + anim.beginTime - beginTime
  }

  /**
   - Returns: a CALayer [keyPath:value] map for animation
   */
  func viewState(targetState: HeroTargetState) -> [String: Any] {
    var targetState = targetState
    var rtn = [String: Any]()

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
    if let opacity = targetState.opacity {
      rtn["opacity"] = NSNumber(value: opacity)
    }
    if let cornerRadius = targetState.cornerRadius {
      rtn["cornerRadius"] = NSNumber(value: cornerRadius.native)
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

    if let transform = targetState.transform {
      rtn["transform"] = NSValue(caTransform3D: transform)
    }
    return rtn
  }

  func animate(delay: TimeInterval) {
    // calculate timing default
    let defaultDuration: TimeInterval
    let defaultTimingFunction: CAMediaTimingFunction

    // timing function
    let fromPos = (state["position"]?.0 as? NSValue)?.cgPointValue ?? snapshot.layer.position
    let toPos = (state["position"]?.1 as? NSValue)?.cgPointValue ?? fromPos
    let fromTransform = (state["transform"]?.0 as? NSValue)?.caTransform3DValue ?? CATransform3DIdentity
    let toTransform = (state["transform"]?.1 as? NSValue)?.caTransform3DValue ?? CATransform3DIdentity
    let realFromPos = CGPoint.zero.transform(fromTransform) + fromPos
    let realToPos = CGPoint.zero.transform(toTransform) + toPos

    if let timingFunction = targetState.timingFunction {
      defaultTimingFunction = timingFunction
    } else if let container = container, !container.bounds.contains(realToPos) {
      // acceleration if leaving screen
      defaultTimingFunction = .acceleration
    } else if let container = container, !container.bounds.contains(realFromPos) {
      // deceleration if entering screen
      defaultTimingFunction = .deceleration
    } else {
      defaultTimingFunction = .standard
    }

    if let duration = targetState.duration {
      defaultDuration = duration
    } else {
      let fromSize = (state["bounds.size"]?.0 as? NSValue)?.cgSizeValue ?? snapshot.layer.bounds.size
      let toSize = (state["bounds.size"]?.1 as? NSValue)?.cgSizeValue ?? fromSize
      let realFromSize = fromSize.transform(fromTransform)
      let realToSize = toSize.transform(toTransform)

      let movePoints = (realFromPos.distance(realToPos) + realFromSize.point.distance(realToSize.point))

      // duration is 0.2 @ 0 to 0.375 @ 500
      defaultDuration = 0.208 + Double(movePoints.clamp(0, 500)) / 3000
    }

    defaultTiming = (defaultDuration, defaultTimingFunction)

    duration = 0
    let beginTime = currentTime + delay
    for (key, (fromValue, toValue)) in state {
      let neededTime = addAnimation(key: key, beginTime:beginTime, fromValue: fromValue, toValue: toValue)
      duration = max(duration, neededTime + delay)
    }
  }
  
  func apply(state: HeroTargetState) {
    let targetState = viewState(targetState: state)
    for (key, targetValue) in targetState {
      if self.state[key] == nil {
        let currentValue = snapshot.layer.value(forKeyPath: key)!
        self.state[key] = (currentValue, currentValue)
      }
      addAnimation(key: key, beginTime: 0, fromValue: targetValue, toValue: targetValue)
    }

    // support changing duration
    if let duration = state.duration {
      self.targetState.duration = duration
      self.duration = duration
      animate(delay: self.targetState.delay - Hero.shared.progress * Hero.shared.totalDuration)
    }
  }

  func resume(timePassed: TimeInterval, reverse: Bool) {
    for (key, (fromValue, toValue)) in state {
      let realToValue = !reverse ? toValue : fromValue
      let realFromValue = (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)!
      state[key] = (realFromValue, realToValue)
    }

    let realDelay = max(0, targetState.delay - timePassed)
    animate(delay: realDelay)
  }

  func seek(layer: CALayer, timePassed: TimeInterval) {
    let timeOffset = timePassed - targetState.delay
    for (key, anim) in layer.animations {
      anim.speed = 0
      anim.timeOffset = max(0, min(anim.duration - 0.01, timeOffset))
      layer.removeAnimation(forKey: key)
      layer.add(anim, forKey: key)
    }
  }

  func seek(timePassed: TimeInterval) {
    seek(layer:snapshot.layer, timePassed:timePassed)
    if let contentLayer = contentLayer {
      seek(layer:contentLayer, timePassed:timePassed)
    }
  }

  func clean() {
    snapshot.layer.removeAllAnimations()
    contentLayer?.removeAllAnimations()
  }

  init(animator: HeroDefaultAnimator, snapshot: UIView, targetState: HeroTargetState, appearing: Bool) {
    self.animator = animator
    self.snapshot = snapshot
    self.targetState = targetState

    let disappeared = viewState(targetState: targetState)

    for (key, disappearedState) in disappeared {
      let appearingState = snapshot.layer.value(forKeyPath: key)
      let toValue = appearing ? appearingState : disappearedState
      let fromValue = !appearing ? appearingState : disappearedState
      state[key] = (fromValue, toValue)
    }

    animate(delay: targetState.delay)
  }
}
