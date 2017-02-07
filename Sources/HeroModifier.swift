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
  public init(applyFunction:@escaping (inout HeroTargetState) -> Void) {
    apply = applyFunction
  }
}

// basic modifiers
extension HeroModifier {
  /**
   Fade the view during transition
   */
  public static var fade = HeroModifier { targetState in
    targetState.opacity = 0
  }

  /**
   Set the position for the view to animate from/to.
   - Parameters:
     - position: position for the view to animate from/to
   */
  public static func position(_ position: CGPoint) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.position = position
    }
  }

  /**
   Set the size for the view to animate from/to.
   - Parameters:
     - size: size for the view to animate from/to
   */
  public static func size(_ size: CGSize) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.size = size
    }
  }
}

// transform modifiers
extension HeroModifier {
  /**
   Set the transform for the view to animate from/to. Will override previous perspective, scale, translate, & rotate modifiers
   - Parameters:
     - t: the CATransform3D object
   */
  public static func transform(_ t: CATransform3D) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = t
    }
  }

  /**
   Set the perspective on the transform. use in combination with the rotate modifier.
   - Parameters:
     - perspective: set the camera distance of the transform
   */
  public static func perspective(_ perspective: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      var transform = targetState.transform ?? CATransform3DIdentity
      transform.m34 = 1.0 / -perspective
      targetState.transform = transform
    }
  }

  /**
   Scale 3d
   - Parameters:
     - x: scale factor on x axis, default 1
     - y: scale factor on y axis, default 1
     - z: scale factor on z axis, default 1
   */
  public static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = CATransform3DScale(targetState.transform ?? CATransform3DIdentity, x, y, z)
    }
  }

  /**
   Scale in x & y axis
   - Parameters:
     - xy: scale factor in both x & y axis
   */
  public static func scale(_ xy: CGFloat) -> HeroModifier {
    return .scale(x: xy, y: xy)
  }

  /**
   Translate 3d
   - Parameters:
     - x: translation distance on x axis in display pixel, default 0
     - y: translation distance on y axis in display pixel, default 0
     - z: translation distance on z axis in display pixel, default 0
   */
  public static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = CATransform3DTranslate(targetState.transform ?? CATransform3DIdentity, x, y, z)
    }
  }

  /**
   Rotate 3d
   - Parameters:
     - x: rotation on x axis in radian, default 0
     - y: rotation on y axis in radian, default 0
     - z: rotation on z axis in radian, default 0
   */
  public static func rotate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.transform = CATransform3DRotate(targetState.transform ?? CATransform3DIdentity, x, 1, 0, 0)
      targetState.transform = CATransform3DRotate(targetState.transform!, y, 0, 1, 0)
      targetState.transform = CATransform3DRotate(targetState.transform!, z, 0, 0, 1)
    }
  }

  /**
   Rotate 2d
   - Parameters:
     - z: rotation in radian
   */
  public static func rotate(_ z: CGFloat) -> HeroModifier {
    return .rotate(z: z)
  }
}


extension HeroModifier {
  /**
   Set the opacity for the view to animate from/to.
   - Parameters:
     - opacity: opacity for the view to animate from/to
   */
  public static func opacity(_ opacity: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.opacity = Float(opacity)
    }
  }

  /**
   Set the cornerRadius for the view to animate from/to.
   - Parameters:
     - cornerRadius: cornerRadius for the view to animate from/to
   */
  public static func cornerRadius(_ cornerRadius: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.cornerRadius = cornerRadius
    }
  }

  /**
   Set the zPosition for the view to animate from/to.
   - Parameters:
   - zPosition: zPosition for the view to animate from/to
   */
  public static func zPosition(_ zPosition: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.zPosition = zPosition
    }
  }

  /**
   Set the borderWidth for the view to animate from/to.
   - Parameters:
   - borderWidth: borderWidth for the view to animate from/to
   */
  public static func borderWidth(_ borderWidth: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.borderWidth = borderWidth
    }
  }

  /**
   Set the borderColor for the view to animate from/to.
   - Parameters:
   - borderColor: borderColor for the view to animate from/to
   */
  public static func borderColor(_ borderColor: UIColor) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.borderColor = borderColor.cgColor
    }
  }

  /**
   Set the shadowColor for the view to animate from/to.
   - Parameters:
   - shadowColor: shadowColor for the view to animate from/to
   */
  public static func shadowColor(_ shadowColor: UIColor) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.shadowColor = shadowColor.cgColor
    }
  }

  /**
   Set the shadowOpacity for the view to animate from/to.
   - Parameters:
   - shadowOpacity: shadowOpacity for the view to animate from/to
   */
  public static func shadowOpacity(_ shadowOpacity: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.shadowOpacity = Float(shadowOpacity)
    }
  }

  /**
   Set the shadowOffset for the view to animate from/to.
   - Parameters:
   - shadowOffset: shadowOffset for the view to animate from/to
   */
  public static func shadowOffset(_ shadowOffset: CGSize) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.shadowOffset = shadowOffset
    }
  }

  /**
   Set the shadowRadius for the view to animate from/to.
   - Parameters:
   - shadowRadius: shadowRadius for the view to animate from/to
   */
  public static func shadowRadius(_ shadowRadius: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.shadowRadius = shadowRadius
    }
  }

  /**
   Set the shadowPath for the view to animate from/to.
   - Parameters:
   - shadowPath: shadowPath for the view to animate from/to
   */
  public static func shadowPath(_ shadowPath: CGPath) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.shadowPath = shadowPath
    }
  }
}

// timing modifiers
extension HeroModifier {
  /**
   Sets the duration of the animation for a given view. If not used, Hero will use determine the duration based on the distance and size changes.
   - Parameters:
     - duration: duration of the animation
   */
  public static func duration(_ duration: TimeInterval) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.duration = duration
    }
  }

  /**
   Sets the delay of the animation for a given view.
   - Parameters:
     - delay: delay of the animation
   */
  public static func delay(_ delay: TimeInterval) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.delay = delay
    }
  }

  /**
   Sets the timing function of the animation for a given view. If not used, Hero will use determine the timing function based on whether or not the view is entering or exiting the screen.
   - Parameters:
     - timingFunction: timing function of the animation
   */
  public static func timingFunction(_ timingFunction: CAMediaTimingFunction) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.timingFunction = timingFunction
    }
  }

  /**
   (iOS 9+) Use spring animation with custom stiffness & damping. The duration will be automatically calculated. Will be ignored if arc, timingFunction, or duration is set.
   - Parameters:
     - stiffness: stiffness of the spring
     - damping: stiffness of the spring
   */
  @available(iOS 9, *)
  public static func spring(stiffness: CGFloat, damping: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.spring = (stiffness, damping)
    }
  }
}

// other modifiers
extension HeroModifier {
  /**
   transition from/to the state of the view with matching heroID
   Will also force the view to use global coordinate space.
   - Parameters:
     - heroID: the source view's heroId.
   */
  public static func source(heroID: String) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.source = heroID
    }
  }

  /**
   Works in combination with position modifier to apply a natural curve when moving to the destination.
   */
  public static var arc: HeroModifier = .arc()
  /**
   Works in combination with position modifier to apply a natural curve when moving to the destination.
   - Parameters:
     - intensity: a value of 1 represent a downward natural curve ╰. a value of -1 represent a upward curve ╮.
       default is 1.
   */
  public static func arc(intensity: CGFloat = 1) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.arc = intensity
    }
  }

  /**
   Cascade applys increasing delay modifiers to subviews
   */
  public static var cascade: HeroModifier = .cascade()

  /**
   Cascade applys increasing delay modifiers to subviews
   - Parameters:
     - delta: delay in between each animation
     - direction: cascade direction
     - delayMatchedViews: whether or not to delay matched subviews until all cascading animation have started
   */
  public static func cascade(delta: TimeInterval = 0.02,
                      direction: CascadeDirection = .topToBottom,
                      delayMatchedViews: Bool = false) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.cascade = (delta, direction, delayMatchedViews)
    }
  }
}

// advance modifiers
extension HeroModifier {
  /**
   Use global coordinate space.
   
   When using global coordinate space. The view become a independent view that is not a subview of any view.
   It won't move when its parent view moves, and won't be affected by parent view's attributes.
   
   When a view is matched, this is automatically enabled.
   The `source` modifier will also enable this.
   
   Global coordinate space is default for all views prior to version 0.1.3
   */
  public static var useGlobalCoordinateSpace: HeroModifier = HeroModifier { targetState in
    targetState.useGlobalCoordinateSpace = true
  }

  /**
   ignore all heroModifiers attributes for a view's direct subviews.
   */
  public static var ignoreSubviewModifiers: HeroModifier = .ignoreSubviewModifiers()
  
  /**
   ignore all heroModifiers attributes for a view's subviews.
   - Parameters:
   - recursive: if false, will only ignore direct subviews' modifiers. default false.
   */
  public static func ignoreSubviewModifiers(recursive: Bool = false) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.ignoreSubviewModifiers = recursive
    }
  }
  
  /**
   Will create snapshot optimized for different view type.
   For custom views or views with masking, useOptimizedSnapshot might create snapshots
   that appear differently than the actual view.
   In that case, use .useNormalSnapshot or .useSlowRenderSnapshot to disable the optimization.
   
   This modifier actually does nothing by itself since .useOptimizedSnapshot is the default.
   */
  public static var useOptimizedSnapshot: HeroModifier = HeroModifier { targetState in
    targetState.snapshotType = .optimized
  }

  /**
   Create snapshot using snapshotView(afterScreenUpdates:).
   */
  public static var useNormalSnapshot: HeroModifier = HeroModifier { targetState in
    targetState.snapshotType = .normal
  }

  /**
   Create snapshot using layer.render(in: currentContext).
   This is slower than .useNormalSnapshot but gives more accurate snapshot for some views (eg. UIStackView).
   */
  public static var useLayerRenderSnapshot: HeroModifier = HeroModifier { targetState in
    targetState.snapshotType = .layerRender
  }
  
  /**
   Force Hero to not create any snapshot when animating this view.
   This will mess up the view hierarchy, therefore, view controllers have to rebuild
   its view structure after the transition finishes.
   */
  public static var useNoSnapshot: HeroModifier = HeroModifier { targetState in
    targetState.snapshotType = .noSnapshot
  }

  /**
   Force Hero use scale based size animation. This will convert all .size modifier into .scale modifier.
   This is to help Hero animate layers that doesn't support bounds animation. Also gives better performance.
   */
  public static var useScaleBasedSizeChange: HeroModifier = HeroModifier { targetState in
    targetState.useScaleBasedSizeChange = true
  }
}

// construct HeroModifier from heroModifierString
extension HeroModifier {
  public static func from(name: String, parameters: [String]) -> HeroModifier? {
    var modifier: HeroModifier?
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
    case "duration":
      if let duration = parameters.getDouble(0) {
        modifier = .duration(duration)
      }
    case "delay":
      if let delay = parameters.getDouble(0) {
        modifier = .delay(delay)
      }
    case "spring":
      if #available(iOS 9, *) {
        modifier = .spring(stiffness: parameters.getCGFloat(0) ?? 250, damping: parameters.getCGFloat(1) ?? 30)
      }
    case "timingFunction":
      if let c1 = parameters.getFloat(0),
        let c2 = parameters.getFloat(1),
        let c3 = parameters.getFloat(2),
        let c4 = parameters.getFloat(3) {
        modifier = .timingFunction(CAMediaTimingFunction(controlPoints: c1, c2, c3, c4))
      } else if let name = parameters.get(0), let timingFunction = CAMediaTimingFunction.from(name:name) {
        modifier = .timingFunction(timingFunction)
      }
    case "arc":
      modifier = .arc(intensity: parameters.getCGFloat(0) ?? 1)
    case "cascade":
      var cascadeDirection = CascadeDirection.topToBottom
      if let directionString = parameters.get(1),
        let direction = CascadeDirection(directionString) {
        cascadeDirection = direction
      }
      modifier = .cascade(delta: parameters.getDouble(0) ?? 0.02, direction: cascadeDirection, delayMatchedViews:parameters.getBool(2) ?? false)
    case "source":
      if let heroID = parameters.get(0) {
        modifier = .source(heroID: heroID)
      }
    case "useGlobalCoordinateSpace":
      modifier = .useGlobalCoordinateSpace
    case "ignoreSubviewModifiers":
      modifier = .ignoreSubviewModifiers(recursive:parameters.getBool(0) ?? false)
    case "zPosition":
      if let zPosition = parameters.getCGFloat(0) {
        modifier = .zPosition(zPosition)
      }
    case "useOptimizedSnapshot":
      modifier = .useOptimizedSnapshot
    case "useNormalSnapshot":
      modifier = .useNormalSnapshot
    case "useLayerRenderSnapshot":
      modifier = .useLayerRenderSnapshot
    case "useNoSnapshot":
      modifier = .useNoSnapshot
    default: break
    }
    return modifier
  }
}
