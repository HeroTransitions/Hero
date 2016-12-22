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
  var view:UIView
  var snapshot:UIView
  var contentLayer:CALayer{
    return snapshot.subviews[0].layer
  }
  var state = [String:(Any, Any)]()
  var parameters = [String:[String]] ()
  var delay:TimeInterval = 0
  var duration:TimeInterval = 0
  
  var timingFunction:CAMediaTimingFunction{
    // get the timing function
    if let curveOptions = parameters["curve"]{
      if let c1 = curveOptions.getFloat(0),
        let c2 = curveOptions.getFloat(1),
        let c3 = curveOptions.getFloat(2),
        let c4 = curveOptions.getFloat(3){
        return CAMediaTimingFunction(controlPoints: c1, c2, c3, c4)
      } else if let ease = curveOptions.get(0), let tf = CAMediaTimingFunction.from(name:ease){
        return  tf
      }
    }
    return .standard
  }
  
  func animation(key:String, fromValue:Any?, toValue:Any?, ignoreArc:Bool = false) -> CAPropertyAnimation {
    let anim:CAPropertyAnimation
    let duration:Double = parameters["duration"]?.getDouble(0) ?? 0.375
    
    let timingFunction = self.timingFunction
    
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
    return anim
  }
  
  func addAnimation(key:String, delay:TimeInterval, fromValue:Any?, toValue:Any?) -> TimeInterval{
    let anim = animation(key: key, fromValue: fromValue, toValue: toValue)
    anim.beginTime = snapshot.layer.convertTime(CACurrentMediaTime(), from: nil) + delay
    
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
      let positionAnim = animation(key: "position", fromValue: fromPosn, toValue: toPosn, ignoreArc: true)
      positionAnim.beginTime = anim.beginTime
      contentLayer.add(positionAnim, forKey: "position")
      contentLayer.add(anim, forKey: key)
    }
    
    return anim.duration
  }
  
  func temporarilySet(modifiers:HeroModifiers){
    let targetState = viewState(for: view, with: modifiers)
    for (key, targetValue) in targetState{
      addAnimation(key: key, delay: 0, fromValue: targetValue, toValue: targetValue)
    }
  }
  
  func resume(timePassed:TimeInterval, reverse:Bool){
    duration = 0
    var realDelay = max(0, delay - timePassed)
    for (key, (fromValue, toValue)) in state{
      var realFromValue = (snapshot.layer.presentation() ?? snapshot.layer).value(forKeyPath: key)
      var realToValue = !reverse ? toValue : fromValue
      
      let neededTime = addAnimation(key: key, delay:realDelay, fromValue: realFromValue, toValue: realToValue)
      duration = max(duration, neededTime + realDelay)
    }
  }
  
  func seek(layer:CALayer, timePassed:TimeInterval){
    let timeOffset = timePassed - delay
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
  
  init(view:UIView, snapshot:UIView, modifiers:HeroModifiers, appearing:Bool){
    self.view = view
    self.snapshot = snapshot
    
    for (key, param) in modifiers {
      parameters[key] = param
    }
    
    if let value = parameters["delay"]?.getFloat(0){
      delay = TimeInterval(value)
    }
    
    let disappeared = viewState(for: view, with: modifiers)
    for (key, disappearedState) in disappeared{
      let appearingState = snapshot.layer.value(forKeyPath: key)
      let toValue = appearing ? appearingState : disappearedState
      let fromValue = !appearing ? appearingState : disappearedState
      state[key] = (fromValue, toValue)
    }
    
    for (key, (fromValue, toValue)) in state{
      let neededTime = addAnimation(key: key, delay:delay, fromValue: fromValue, toValue: toValue)
      duration = max(duration, neededTime + delay)
    }
  }
}
