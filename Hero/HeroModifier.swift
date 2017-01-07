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

public class HeroModifier {
  internal let apply:(inout HeroTargetState) -> Void
  public init(applyFunction:@escaping (inout HeroTargetState) -> Void){
    apply = applyFunction
  }
  
  public static func from(name:String, parameters:[String]) -> HeroModifier? {
    var modifier:HeroModifier?
    switch name {
    case "fade":
      modifier = .fade
    case "position":
      modifier = .position(CGPoint(x: parameters.getCGFloat(0) ?? 0, y: parameters.getCGFloat(1) ?? 0))
    case "size":
      modifier = .size(CGSize(width: parameters.getCGFloat(0) ?? 0, height: parameters.getCGFloat(1) ?? 0))
    case "scale":
      if parameters.count == 1 {
        modifier = .scale(parameters.getCGFloat(0) ?? 1)
      } else {
        modifier = .scale(x: parameters.getCGFloat(0) ?? 1,
                          y: parameters.getCGFloat(1) ?? 1,
                          z: parameters.getCGFloat(2) ?? 1)
      }
    case "rotate":
      if parameters.count == 1 {
        modifier = .rotate(parameters.getCGFloat(0) ?? 0)
      } else {
        modifier = .rotate(x: parameters.getCGFloat(0) ?? 0,
                           y: parameters.getCGFloat(1) ?? 0,
                           z: parameters.getCGFloat(2) ?? 0)
      }
    case "translate":
      modifier = .translate(x: parameters.getCGFloat(0) ?? 0,
                            y: parameters.getCGFloat(1) ?? 0,
                            z: parameters.getCGFloat(2) ?? 0)
    case "zPosition":
      if let zPosition = parameters.getCGFloat(0){
        modifier = .zPosition(zPosition)
      }
    case "duration":
      if let duration = parameters.getDouble(0){
        modifier = .duration(duration)
      }
    case "delay":
      if let delay = parameters.getDouble(0){
        modifier = .delay(delay)
      }
    case "spring":
      modifier = .spring(stiffness: parameters.getCGFloat(0) ?? 250, damping: parameters.getCGFloat(1) ?? 30)
    case "timingFunction":
      if let c1 = parameters.getFloat(0),
        let c2 = parameters.getFloat(1),
        let c3 = parameters.getFloat(2),
        let c4 = parameters.getFloat(3){
        modifier = .timingFunction(CAMediaTimingFunction(controlPoints: c1, c2, c3, c4))
      } else if let name = parameters.get(0), let timingFunction = CAMediaTimingFunction.from(name:name){
        modifier = .timingFunction(timingFunction)
      }
    case "arc":
      modifier = .arc(intensity: parameters.getCGFloat(0) ?? 1)
    case "cascade":
      var cascadeDirection = CascadePreprocessor.CascadeDirection.topToBottom
      if let directionString = parameters.get(1),
         let direction = CascadePreprocessor.CascadeDirection(directionString) {
        cascadeDirection = direction
      }
      modifier = .cascade(delta: parameters.getDouble(0) ?? 0.02, direction: cascadeDirection, delayMatchedViews:parameters.getBool(2) ?? false)
    case "source":
      if let heroID = parameters.get(0){
        modifier = .source(heroID: heroID)
      }
    case "ignoreSubviewModifiers":
      modifier = .ignoreSubviewModifiers
    case "zPosition":
      if let zPosition = parameters.getCGFloat(0){
        modifier = .zPosition(zPosition)
      }
    case "zPositionIfMatched":
      if let zPosition = parameters.getCGFloat(0){
        modifier = .zPositionIfMatched(zPosition)
      }
    default: break
    }
    return modifier
  }
}


// basic modifiers
extension HeroModifier {
  public static var fade = HeroModifier { targetState in
    targetState.opacity = 0
  }
  
  public static func position(_ position:CGPoint) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.position = position
    }
  }
  
  public static func size(_ size:CGSize) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.size = size
    }
  }
}

// transform modifiers
extension HeroModifier {
  public static func transform(_ t:CATransform3D) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = t
    }
  }

  public static func perspective(_ perspective:CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      var transform = targetState.transform ?? CATransform3DIdentity
      transform.m34 = 1.0 / -perspective
      targetState.transform = transform
    }
  }
  
  public static func scale(x:CGFloat = 1, y:CGFloat = 1, z:CGFloat = 1) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = CATransform3DScale(targetState.transform ?? CATransform3DIdentity, x, y, z)
    }
  }
  
  public static func scale(_ xy:CGFloat) -> HeroModifier {
    return .scale(x: xy, y: xy)
  }

  public static func translate(x:CGFloat = 0, y:CGFloat = 0, z:CGFloat = 0) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = CATransform3DTranslate(targetState.transform ?? CATransform3DIdentity, x, y, z)
    }
  }
  
  public static func rotate(x:CGFloat = 0, y:CGFloat = 0, z:CGFloat = 0) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = CATransform3DRotate(targetState.transform ?? CATransform3DIdentity, x, 1, 0, 0)
      targetState.transform = CATransform3DRotate(targetState.transform!, y, 0, 1, 0)
      targetState.transform = CATransform3DRotate(targetState.transform!, z, 0, 0, 1)
    }
  }
  
  public static func rotate(_ z:CGFloat) -> HeroModifier {
    return .rotate(z: z)
  }
}

// timing modifiers
extension HeroModifier {
  public static func duration(_ duration:TimeInterval) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.duration = duration
    }
  }
  
  public static func delay(_ delay:TimeInterval) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.delay = delay
    }
  }
  
  public static func timingFunction(_ timingFunction:CAMediaTimingFunction) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.timingFunction = timingFunction
    }
  }
  
  public static func spring(stiffness:CGFloat, damping:CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.spring = (stiffness, damping)
    }
  }
}

// other modifiers
extension HeroModifier {
  public static func zPosition(_ zPosition:CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.zPosition = zPosition
    }
  }
  
  public static func zPositionIfMatched(_ zPositionIfMatched:CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.zPositionIfMatched = zPositionIfMatched
    }
  }
  
  public static var ignoreSubviewModifiers = HeroModifier { targetState in
    targetState.ignoreSubviewModifiers = true
  }
  
  public static func source(heroID:String) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.source = heroID
    }
  }
  
  public static var arc:HeroModifier = .arc()
  public static func arc(intensity:CGFloat = 1) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.arc = intensity
    }
  }

  
  // Cascade applys increasing delay modifiers to subviews
  // the first parameter is the delay in between each animation
  // the second parameter is the direction
  // the third is whether or not to delay matched subviews
  //
  // NOTE: matched views(views with the same `heroID`) won't have
  // the cascading effect. however, you can use the 3rd parameter to delay
  // the start time until the last cascading animation have started
  // by default: the matched views will animate simutanously with the cascading views
  public static var cascade:HeroModifier = .cascade()
  public static func cascade(delta:TimeInterval = 0.02,
                      direction:CascadePreprocessor.CascadeDirection = .topToBottom,
                      delayMatchedViews:Bool = false) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.cascade = (delta, direction, delayMatchedViews)
    }
  }
}
