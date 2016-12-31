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
  weak var animator:HeroDefaultAnimator?
  var view:UIView
  var snapshot:UIView
  var state = [String:(Any, Any)]()
  var parameters = [String:[String]] ()
  var baseDelay:TimeInterval = 0
  var duration:TimeInterval = 0
  
  var parsedDuration:TimeInterval?
  var parsedTimingFunction:CAMediaTimingFunction?
  var defaultTiming:(TimeInterval, CAMediaTimingFunction)!
  
  // computed
  var contentLayer:CALayer{
    return snapshot.subviews[0].layer
  }
  var currentTime:TimeInterval{
    return snapshot.layer.convertTime(CACurrentMediaTime(), from: nil)
  }
  var container:UIView{
    return animator!.context.container
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
  
  func getAnimation(key:String, beginTime:TimeInterval, fromValue:Any?, toValue:Any?, ignoreArc:Bool = false) -> CAPropertyAnimation {
    let anim:CAPropertyAnimation
    
    let (delay, duration, timingFunction) = (0.0, defaultTiming.0, defaultTiming.1)
    // getTiming(key: key, fromValue: fromValue, toValue: toValue)
    
    if !ignoreArc, key == "position", let arcOptions = parameters["arc"],
      let fromPos = (fromValue as? NSValue)?.cgPointValue,
      let toPos = (toValue as? NSValue)?.cgPointValue,
      abs(fromPos.x - toPos.x) >= 1, abs(fromPos.y - toPos.y) >= 1 {
      let arcIntensity = arcOptions.getCGFloat(0) ?? 1
      let kanim = CAKeyframeAnimation(keyPath: key)
      
      let path = CGMutablePath()
      let maxControl = fromPos.y > toPos.y ? CGPoint(x: toPos.x, y: fromPos.y) : CGPoint(x: fromPos.x, y: toPos.y)
      let minControl = (toPos - fromPos) / 2 + fromPos
      let diff = abs(toPos - fromPos)
      
      path.move(to: fromPos)
      path.addQuadCurve(to: toPos, control: minControl + (maxControl - minControl) * arcIntensity)
      
      kanim.values = [fromValue!, toValue!]
      kanim.path = path
      kanim.duration = duration
      kanim.timingFunctions = [timingFunction]
      anim = kanim
    } else if #available(iOS 9.0, *), key != "cornerRadius", let springOptions = parameters["spring"] {
      let sanim = CASpringAnimation(keyPath: key)
      sanim.stiffness = (springOptions.getCGFloat(0) ?? 250)
      sanim.damping = (springOptions.getCGFloat(1) ?? 30)
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
  func addAnimation(key:String, beginTime:TimeInterval, fromValue:Any?, toValue:Any?) -> TimeInterval{
    let anim = getAnimation(key: key, beginTime:beginTime, fromValue: fromValue, toValue: toValue)
    
    snapshot.layer.add(anim, forKey: key)
    if key == "cornerRadius"{
      contentLayer.add(anim, forKey: key)
    } else if key == "bounds.size"{
      let fromSize = (fromValue as! NSValue).cgSizeValue
      let toSize = (toValue as! NSValue).cgSizeValue
      
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
      
      contentLayer.add(positionAnim, forKey: "position")
      contentLayer.add(anim, forKey: key)
    }
    
    return anim.duration + anim.beginTime - beginTime
  }
  
  func animate(delay:TimeInterval) {
    // calculate timing default
    let defaultDuration:TimeInterval
    let defaultTimingFunction:CAMediaTimingFunction
    
    // timing function
    let fromPos = (state["position"]?.0 as? NSValue)?.cgPointValue ?? snapshot.layer.position
    let toPos = (state["position"]?.1 as? NSValue)?.cgPointValue ?? fromPos
    let fromTransform = (state["transform"]?.0 as? NSValue)?.caTransform3DValue ?? CATransform3DIdentity
    let toTransform = (state["transform"]?.1 as? NSValue)?.caTransform3DValue ?? CATransform3DIdentity
    let realFromPos = CGPoint.zero.transform(fromTransform) + fromPos
    let realToPos = CGPoint.zero.transform(toTransform) + toPos
    
    if let parsedTimingFunction = parsedTimingFunction{
      defaultTimingFunction = parsedTimingFunction
    } else if !container.bounds.contains(realToPos){
      // acceleration if leaving screen
      defaultTimingFunction = .acceleration
    } else if !container.bounds.contains(realFromPos){
      // deceleration if entering screen
      defaultTimingFunction = .deceleration
    } else {
      defaultTimingFunction = .standard
    }

    if let parsedDuration = parsedDuration {
      defaultDuration = parsedDuration
    } else {
      let fromSize = (state["bounds.size"]?.0 as? NSValue)?.cgSizeValue ?? snapshot.layer.bounds.size
      let toSize = (state["bounds.size"]?.1 as? NSValue)?.cgSizeValue ?? fromSize
      let realFromSize = fromSize.transform(fromTransform)
      let realToSize = toSize.transform(toTransform)
      
      var movePoints = (realFromPos.distance(realToPos) + realFromSize.point.distance(realToSize.point))
      
      // duration is 0.2 @ 0 to 0.375 @ 500
      defaultDuration = 0.208 + Double(movePoints.clamp(0, 500)) / 3000
    }
    
    defaultTiming = (defaultDuration, defaultTimingFunction)

    duration = 0
    let beginTime = currentTime + delay
    for (key, (fromValue, toValue)) in state{
      let neededTime = addAnimation(key: key, beginTime:beginTime, fromValue: fromValue, toValue: toValue)
      duration = max(duration, neededTime + delay)
    }
  }
  
  func temporarilySet(modifiers:HeroModifiers){
    let targetState = viewState(for: view, with: modifiers)
    for (key, targetValue) in targetState{
      if state[key] == nil{
        let currentValue = snapshot.layer.value(forKeyPath: key)
        state[key] = (currentValue, currentValue)
      }
      addAnimation(key: key, beginTime: 0, fromValue: targetValue, toValue: targetValue)
    }
  }
  
  func resume(timePassed:TimeInterval, reverse:Bool){
    for (key, (fromValue, toValue)) in state{
      var realToValue = !reverse ? toValue : fromValue
      var realFromValue = (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)
      state[key] = (realFromValue, realToValue)
    }
    
    var realDelay = max(0, baseDelay - timePassed)
    animate(delay: realDelay)
  }
  
  func seek(layer:CALayer, timePassed:TimeInterval){
    let timeOffset = timePassed - baseDelay
    for (key, anim) in layer.animations {
      anim.speed = 0
      anim.timeOffset = max(0, min(anim.duration - 0.01, timeOffset))
      layer.removeAnimation(forKey: key)
      layer.add(anim, forKey: key)
    }
  }
  
  func seek(timePassed:TimeInterval){
    seek(layer:snapshot.layer, timePassed:timePassed)
    seek(layer:contentLayer, timePassed:timePassed)
  }
  
  init(animator:HeroDefaultAnimator, view:UIView, snapshot:UIView, modifiers:HeroModifiers, appearing:Bool){
    self.animator = animator
    self.view = view
    self.snapshot = snapshot
    
    for (key, param) in modifiers {
      parameters[key] = param
    }
    
    parsedDuration = parameters["duration"]?.getDouble(0)
    if let curveOptions = parameters["curve"]{
      if let c1 = curveOptions.getFloat(0),
        let c2 = curveOptions.getFloat(1),
        let c3 = curveOptions.getFloat(2),
        let c4 = curveOptions.getFloat(3){
        parsedTimingFunction = CAMediaTimingFunction(controlPoints: c1, c2, c3, c4)
      } else if let ease = curveOptions.get(0), let tf = CAMediaTimingFunction.from(name:ease){
        parsedTimingFunction = tf
      }
    }
    
    if let value = parameters["delay"]?.getFloat(0){
      baseDelay = TimeInterval(value)
    }
    
    let disappeared = viewState(for: view, with: modifiers)
    for (key, disappearedState) in disappeared{
      let appearingState = snapshot.layer.value(forKeyPath: key)
      let toValue = appearing ? appearingState : disappearedState
      let fromValue = !appearing ? appearingState : disappearedState
      state[key] = (fromValue, toValue)
    }
    
    animate(delay: baseDelay)
  }
}
