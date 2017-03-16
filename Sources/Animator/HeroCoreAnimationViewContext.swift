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

internal class HeroCoreAnimationViewContext: HeroAnimatorViewContext {

  var state = [String: (Any?, Any?)]()
  var timingFunction: CAMediaTimingFunction = .standard

  // computed
  var contentLayer: CALayer? {
    return snapshot.layer.sublayers?.get(0)
  }
  var overlayLayer: CALayer?

  override class func canAnimate(view: UIView, state: HeroTargetState, appearing: Bool) -> Bool {
    return  state.position != nil ||
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

  func getOverlayLayer() -> CALayer {
    if overlayLayer == nil {
      overlayLayer = CALayer()
      overlayLayer!.frame = snapshot.bounds
      overlayLayer!.opacity = 0
      snapshot.layer.addSublayer(overlayLayer!)
    }
    return overlayLayer!
  }

  func overlayKeyFor(key: String) -> String? {
    if key.hasPrefix("overlay.") {
      var key = key
      key.removeSubrange(key.startIndex..<key.index(key.startIndex, offsetBy: 8))
      return key
    }
    return nil
  }

  func currentValue(key: String) -> Any? {
    if let key = overlayKeyFor(key: key) {
      return overlayLayer?.value(forKeyPath: key)
    }
    return (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)
  }

  func getAnimation(key: String, beginTime: TimeInterval, fromValue: Any?, toValue: Any?, ignoreArc: Bool = false) -> CAPropertyAnimation {
    let key = overlayKeyFor(key: key) ?? key
    let anim: CAPropertyAnimation

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
    anim.beginTime = beginTime
    return anim
  }

  // return the completion duration of the animation (duration + initial delay, not counting the beginTime)
  func animate(key: String, beginTime: TimeInterval, fromValue: Any?, toValue: Any?) -> TimeInterval {
    let anim = getAnimation(key: key, beginTime:beginTime, fromValue: fromValue, toValue: toValue)

    if let overlayKey = overlayKeyFor(key:key) {
      getOverlayLayer().add(anim, forKey: overlayKey)
    } else {
      snapshot.layer.add(anim, forKey: key)
      switch key {
      case "cornerRadius", "contentsRect", "contentsScale":
        contentLayer?.add(anim, forKey: key)
        overlayLayer?.add(anim, forKey: key)
      case "bounds.size":
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

        overlayLayer?.add(positionAnim, forKey: "position")
        overlayLayer?.add(anim, forKey: key)
      default: break
      }
    }

    return anim.duration + anim.beginTime - beginTime
  }

  func animate(delay: TimeInterval) {
    if let tf = targetState.timingFunction {
      timingFunction = tf
    }

    duration = targetState.duration!

    let beginTime = currentTime + delay
    var finalDuration: TimeInterval = duration
    for (key, (fromValue, toValue)) in state {
      let neededTime = animate(key: key, beginTime: beginTime, fromValue: fromValue, toValue: toValue)
      finalDuration = max(finalDuration, neededTime + delay)
    }

    duration = finalDuration
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
      let _ = animate(key: key, beginTime: 0, fromValue: targetValue, toValue: targetValue)
    }
  }

  override func resume(timePassed: TimeInterval, reverse: Bool) {
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

  func seek(layer: CALayer, timePassed: TimeInterval) {
    let timeOffset = timePassed - targetState.delay
    for (key, anim) in layer.animations {
      anim.speed = 0
      anim.timeOffset = max(0, min(anim.duration - 0.01, timeOffset))
      layer.removeAnimation(forKey: key)
      layer.add(anim, forKey: key)
    }
  }

  override func seek(timePassed: TimeInterval) {
    seek(layer:snapshot.layer, timePassed:timePassed)
    if let contentLayer = contentLayer {
      seek(layer:contentLayer, timePassed:timePassed)
    }
    if let overlayLayer = overlayLayer {
      seek(layer: overlayLayer, timePassed: timePassed)
    }
  }

  override func clean() {
    super.clean()
    overlayLayer = nil
  }

  override func startAnimations(appearing: Bool) {
    if let beginState = targetState.beginState?.state {
      let appeared = viewState(targetState: beginState)
      for (key, value) in appeared {
        snapshot.layer.setValue(value, forKeyPath: key)
      }
      if let (color, opacity) = beginState.overlay {
        let overlay = getOverlayLayer()
        overlay.backgroundColor = color
        overlay.opacity = Float(opacity)
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
