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

public class HeroDefaultAnimator:HeroAnimator{
  var snapshots:[UIView:UIView] = [:]
  
  var duration:TimeInterval = HeroDefaultAnimator.defaultAnimationDuration
  static let defaultAnimationDuration:TimeInterval = 0.5

  var context:HeroContext!
  var animationGroups:[CALayer:(TimeInterval, CAAnimationGroup)] = [:]
  let animatableOptions:Set<String> = ["fade", "opacity", "position", "bounds", "anchorPoint", "cornerRadius", "transform", "scale", "translate", "rotate", "forceAnimate"]
  var removedAnimations:[(CALayer, CABasicAnimation)] = []
  var paused = true
  
  public func seekTo(progress:Double) {
    paused = true
    for (layer, (delay, anim)) in animationGroups{
      anim.speed = 0
      let timeOffset = progress * duration - delay
      anim.timeOffset = max(0, min(anim.duration - 0.01, timeOffset))
      layer.removeAnimation(forKey: "hero")
      layer.add(anim, forKey: "hero")
    }
  }
  
  public func resume(from progress:Double, reverse:Bool) -> TimeInterval{
    paused = false
    let timePassed = (reverse ? 1 - progress : progress) * duration
    
    var neededTime:TimeInterval = self.duration - timePassed
    for (layer, anim) in removedAnimations{
      anim.fillMode = kCAFillModeBoth
      anim.isRemovedOnCompletion = false
      if #available(iOS 9.0, *), let anim = anim as? CASpringAnimation{
        anim.speed = 1
        if reverse {
          anim.toValue = anim.fromValue
        }
        anim.fromValue = layer.value(forKeyPath: anim.keyPath!)
        neededTime = max(neededTime, anim.settlingDuration)
      } else {
        anim.speed = reverse ? -1 : 1
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        if reverse{
          anim.toValue = layer.value(forKeyPath: anim.keyPath!)
        } else {
          anim.fromValue = layer.value(forKeyPath: anim.keyPath!)
        }
      }
    }
    for (layer, (delay, group)) in animationGroups{
      group.speed = reverse ? -1 : 1
      group.timeOffset = 0
      if reverse{
        let timePassed = (1 - progress) * (delay + group.duration)
        group.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - timePassed
      } else {
        group.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + delay - timePassed
      }
    }
    for (layer, (_, group)) in animationGroups{
      layer.removeAnimation(forKey: "hero")
      layer.add(group, forKey: "hero")
    }
    for (layer, anim) in removedAnimations{
      anim.duration = neededTime
      layer.add(anim, forKey: "hero_\(anim.keyPath!)")
    }
    return neededTime
  }
  
  public func temporarilySet(view:UIView, to modifiers:HeroModifiers){
    guard let snapshot = snapshots[view] else {
      print("HERO: unable to temporarily set to \(view). The view must be running at least one animation before it can be interactively changed")
      return
    }
    let (_, group) = animationGroups[snapshot.layer]!
    let state = viewState(for: view, with: modifiers)
    for (key, targetValue) in state{
      if let index = group.animations!.index(where:{ return ($0 as! CABasicAnimation).keyPath == key }) {
        let anim = group.animations!.remove(at: index) as! CABasicAnimation
        removedAnimations.append((snapshot.layer, anim))
      } else if removedAnimations.index(where: { return $0.0 == snapshot.layer && $0.1.keyPath == key }) == nil{
        let originValue = snapshot.layer.value(forKeyPath: key)
        let anim = animation(for:view, key: key, fromValue: originValue, toValue: originValue)
        removedAnimations.append((snapshot.layer, anim))
      }
      snapshot.layer.setValue(targetValue, forKeyPath: key)
      if key == "bounds"{
        let contentLayer = snapshot.subviews[0].layer
        if removedAnimations.index(where: { return $0.0 == contentLayer }) == nil{
          if let (_, group) = animationGroups[contentLayer]{
            for anim in group.animations!{
              removedAnimations.append((contentLayer, anim as! CABasicAnimation))
            }
          } else {
            let originBounds = contentLayer.value(forKeyPath: "bounds")
            removedAnimations.append((contentLayer, animation(for:view, key: "bounds", fromValue: originBounds, toValue: originBounds)))
            let originPos = contentLayer.value(forKeyPath: "position")
            removedAnimations.append((contentLayer, animation(for:view, key: "position", fromValue: originPos, toValue: originPos)))
          }
        }
        contentLayer.bounds = (targetValue as! NSValue).cgRectValue
        contentLayer.position = contentLayer.bounds.center
      }
    }
    snapshot.layer.removeAnimation(forKey: "hero")
    snapshot.layer.add(group, forKey: "hero")
  }

  public func canAnimate(context:HeroContext, view:UIView, appearing:Bool) -> Bool{
    if let modifierNames = context.modifierNames(for: view){
      return self.animatableOptions.intersection(Set(modifierNames)).count > 0
    }
    return false
  }
  
  public func animate(context:HeroContext, fromViews:[UIView], toViews:[UIView]) -> TimeInterval{
    self.paused = false
    self.context = context
    let container = context.container

    let animatingViews = fromViews + toViews
    
    // take a snapshot view for each animating views
    for v in animatingViews {
      v.isHidden = false

      // capture a snapshot without cornerRadius
      let oldCornerRadius = v.layer.cornerRadius
      v.layer.cornerRadius = 0
      let snapshot = v.snapshotView(afterScreenUpdates: true)!
      v.layer.cornerRadius = oldCornerRadius
      
      // the Snapshot's contentView must have hold the cornerRadius value,
      // since the snapshot might not have maskToBounds set
      let contentView = snapshot.subviews[0]
      contentView.layer.cornerRadius = v.layer.cornerRadius
      contentView.layer.masksToBounds = true
      
      snapshot.layer.cornerRadius = v.layer.cornerRadius
      if let zPos = context[v, "zPosition"]?.getCGFloat(0){
        snapshot.layer.zPosition = zPos
      } else {
        snapshot.layer.zPosition = v.layer.zPosition
      }
      snapshot.layer.opacity = v.layer.opacity
      snapshot.layer.isOpaque = v.layer.isOpaque
      snapshot.layer.anchorPoint = v.layer.anchorPoint
      snapshot.layer.masksToBounds = v.layer.masksToBounds
      snapshot.layer.borderColor = v.layer.borderColor
      snapshot.layer.borderWidth = v.layer.borderWidth
      snapshot.layer.transform = v.layer.transform
      snapshot.layer.shadowRadius = v.layer.shadowRadius
      snapshot.layer.shadowOpacity = v.layer.shadowOpacity
      snapshot.layer.shadowColor = v.layer.shadowColor
      snapshot.layer.shadowOffset = v.layer.shadowOffset
      
      snapshot.frame = container.convert(v.bounds, from: v)
      snapshot.heroID = v.heroID

      snapshots[v] = snapshot
      v.isHidden = true
      
      // insert below views from other plugins
      container.addSubview(snapshot)
    }
    
    // animate
    for v in fromViews{
      animate(view: v, appearing: false)
    }
    for v in toViews{
      animate(view: v, appearing: true)
    }

    return duration
  }

  public func clean(){
    for (_, snapshot) in snapshots{
      snapshot.removeFromSuperview()
    }
    paused = true
    context = nil
    removedAnimations.removeAll()
    animationGroups.removeAll()
    snapshots.removeAll()
  }
}


private extension HeroDefaultAnimator {
  func viewState(for view:UIView, with modifiers:HeroModifiers) -> [String:Any]{
    var rtn = [String:Any]()
    for (className, option) in modifiers{
      switch className {
      case "bounds":
        if let rect = CGRect(modifierParameters:option){
          rtn["bounds"] = NSValue(cgRect:rect)
        }
      case "position":
        if let point = CGPoint(modifierParameters:option){
          rtn["position"] = NSValue(cgPoint:point)
        }
      case "anchorPoint":
        if let point = CGPoint(modifierParameters:option){
          rtn["anchorPoint"] = NSValue(cgPoint:point)
        }
      case "fade":
        rtn["opacity"] = NSNumber(value: 0)
      case "cornerRadius":
        if let cr = option.getFloat(0) {
          rtn["cornerRadius"] = NSNumber(value: cr)
        }
      case "transform":
        if let transform = CATransform3D(modifierParameters: option){
          rtn["transform"] = NSValue(caTransform3D:transform)
        }
      case "perspective", "scale", "translate", "rotate":
        var t = (rtn["transform"] as? NSValue)?.caTransform3DValue ?? view.layer.transform
        switch className {
        case "perspective":
          t.m34 = 1.0 / -(option.getCGFloat(0) ?? 500)
        case "scale":
          if option.count == 1{
            // default scale on both x & y
            t = CATransform3DScale(t,
                                   CGFloat(Float(option.get(0) ?? "") ?? 1),
                                   CGFloat(Float(option.get(0) ?? "") ?? 1),
                                   1)
          } else {
            t = CATransform3DScale(t,
                                   CGFloat(Float(option.get(0) ?? "") ?? 1),
                                   CGFloat(Float(option.get(1) ?? "") ?? 1),
                                   CGFloat(Float(option.get(2) ?? "") ?? 1))
          }
        case "translate":
          t = CATransform3DTranslate(t,
                                     option.getCGFloat(0) ?? 0,
                                     option.getCGFloat(1) ?? 0,
                                     option.getCGFloat(2) ?? 0)
        case "rotate":
          if option.count == 1{
            // default rotate on z axis
            t = CATransform3DRotate(t, CGFloat(Float(option.get(0) ?? "") ?? 0), 0, 0, 1)
          } else {
            t = CATransform3DRotate(t, CGFloat(Float(option.get(0) ?? "") ?? 0), 1, 0, 0)
            t = CATransform3DRotate(t, CGFloat(Float(option.get(1) ?? "") ?? 0), 0, 1, 0)
            t = CATransform3DRotate(t, CGFloat(Float(option.get(2) ?? "") ?? 0), 0, 0, 1)
          }
        default: break
        }
        rtn["transform"] = NSValue(caTransform3D:t)
      default: break
      }
    }
    return rtn
  }
  
  func animation(for view:UIView, key:String, fromValue:Any?, toValue:Any?) -> CABasicAnimation {
    let anim:CABasicAnimation
    
    if #available(iOS 9.0, *), key != "cornerRadius", context[view, "duration"] == nil, context[view, "curve"] == nil {
      let sanim = CASpringAnimation(keyPath: key)
      sanim.stiffness = (context[view, "spring"]?.getCGFloat(0) ?? 150)
      sanim.damping = (context[view, "spring"]?.getCGFloat(1) ?? 20)
      anim = sanim
      anim.duration = sanim.settlingDuration * 0.9
    } else {
      anim = CABasicAnimation(keyPath: key)
      anim.duration = context[view, "duration"]?.getDouble(0) ?? HeroDefaultAnimator.defaultAnimationDuration
      anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      if let curveOptions = context[view, "curve"]{
        if let c1 = curveOptions.getFloat(0),
           let c2 = curveOptions.getFloat(1),
           let c3 = curveOptions.getFloat(2),
           let c4 = curveOptions.getFloat(3){
          anim.timingFunction = CAMediaTimingFunction(controlPoints: c1, c2, c3, c4)
        } else if let ease = curveOptions.get(0){
          switch ease {
          case "linear":
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
          case "easeIn":
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
          case "easeOut":
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
          default:
            break
          }
        }
      }
    }
    
    anim.fillMode = kCAFillModeBoth
    anim.isRemovedOnCompletion = false
    anim.fromValue = fromValue
    anim.toValue = toValue
    return anim
  }
  
  func applyAnimations(animations:[CAAnimation], to layer:CALayer, delay:TimeInterval, duration:TimeInterval){
    let group = CAAnimationGroup()
    if delay > 0{
      group.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) + delay
    }
    group.duration = duration
    group.fillMode = kCAFillModeBoth
    group.isRemovedOnCompletion = false
    group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    group.animations = animations
    layer.add(group, forKey: "hero")
    layer.needsDisplayOnBoundsChange = true
    self.animationGroups[layer] = (delay, group)
  }
  
  func animate(view:UIView, appearing:Bool){
    let snapshot = snapshots[view]!
    let disappeared = viewState(for: view, with: context[view]!)

    var maxDuration:TimeInterval = HeroDefaultAnimator.defaultAnimationDuration

    var animations:[CAAnimation] = []
    var contentViewAnims:[CAAnimation] = []
    for (k, disappearedState) in disappeared{
      let appearingState = snapshot.layer.value(forKeyPath: k)
      let toValue = appearing ? appearingState : disappearedState
      let fromValue = !appearing ? appearingState : disappearedState
      let anim = animation(for:view, key: k, fromValue: fromValue, toValue: toValue)
      maxDuration = max(maxDuration, anim.duration)
      
      animations.append(anim)
      if k == "cornerRadius"{
        contentViewAnims.append(anim)
      } else {
        if k == "bounds"{
          let fromBounds = (fromValue as! NSValue).cgRectValue
          let toBounds = (toValue as! NSValue).cgRectValue
          
          // for the snapshotView(UIReplicantView): there is a
          // subview(UIReplicantContentView) that is hosting the real snapshot image.
          // because we are using CAAnimations and not UIView animations,
          // The snapshotView will not layout during animations.
          // we have to add two more animations to manually layout the content view.
          
          let fromPosn = NSValue(cgPoint:fromBounds.center)
          let toPosn = NSValue(cgPoint:toBounds.center)
          let positionAnim = animation(for: view, key: "position", fromValue: fromPosn, toValue: toPosn)
          let boundsAnim = animation(for: view, key: "bounds", fromValue: fromValue, toValue: toValue)
          contentViewAnims.append(positionAnim)
          contentViewAnims.append(boundsAnim)
        }
      }
    }
    
    let delay = TimeInterval(context[view, "delay"]?.getFloat(0) ?? 0)
    duration = max(duration, maxDuration + delay)
    applyAnimations(animations: animations, to: snapshot.layer, delay: delay, duration: maxDuration)

    if contentViewAnims.count > 0{
      let contentLayer = snapshot.subviews[0].layer
      applyAnimations(animations: contentViewAnims, to: contentLayer, delay: delay, duration: maxDuration)
    }
  }
}
