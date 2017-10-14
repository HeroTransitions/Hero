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

public final class HeroModifier {
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
   Force don't fade view during transition
   */
  public static var forceNonFade = HeroModifier { targetState in
    targetState.nonFade = true
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

  public static func translate(_ point: CGPoint, z: CGFloat = 0) -> HeroModifier {
    return translate(x: point.x, y: point.y, z: z)
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

  public static func rotate(_ point: CGPoint, z: CGFloat = 0) -> HeroModifier {
    return rotate(x: point.x, y: point.y, z: z)
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
   Set the backgroundColor for the view to animate from/to.
   - Parameters:
   - backgroundColor: backgroundColor for the view to animate from/to
   */
  public static func backgroundColor(_ backgroundColor: UIColor) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.backgroundColor = backgroundColor.cgColor
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
   Set the contentsRect for the view to animate from/to.
   - Parameters:
   - contentsRect: contentsRect for the view to animate from/to
   */
  public static func contentsRect(_ contentsRect: CGRect) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.contentsRect = contentsRect
    }
  }

  /**
   Set the contentsScale for the view to animate from/to.
   - Parameters:
   - contentsScale: contentsScale for the view to animate from/to
   */
  public static func contentsScale(_ contentsScale: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.contentsScale = contentsScale
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

  /**
   Set the masksToBounds for the view to animate from/to.
   - Parameters:
   - masksToBounds: masksToBounds for the view to animate from/to
   */
  public static func masksToBounds(_ masksToBounds: Bool) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.masksToBounds = masksToBounds
    }
  }

  /**
   Create an overlay on the animating view.
   - Parameters:
     - color: color of the overlay
     - opacity: opacity of the overlay
   */
  public static func overlay(color: UIColor, opacity: CGFloat) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.overlay = (color.cgColor, opacity)
    }
  }
}

// timing modifiers
extension HeroModifier {
  /**
   Sets the duration of the animation for a given view. If not used, Hero will use determine the duration based on the distance and size changes.
   - Parameters:
     - duration: duration of the animation
   
   Note: a duration of .infinity means matching the duration of the longest animation. same as .durationMatchLongest
   */
  public static func duration(_ duration: TimeInterval) -> HeroModifier {
    return HeroModifier { targetState in
      targetState.duration = duration
    }
  }

  /**
   Sets the duration of the animation for a given view to match the longest animation of the transition.
   */
  public static var durationMatchLongest: HeroModifier = HeroModifier { targetState in
    targetState.duration = .infinity
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
     - damping: damping of the spring
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
   Transition from/to the state of the view with matching heroID
   Will also force the view to use global coordinate space.
   
   The following layer properties will be animated from the given view.

       position
       bounds.size
       cornerRadius
       transform
       shadowColor
       shadowOpacity
       shadowOffset
       shadowRadius
       shadowPath

   Note that the following properties **won't** be taken from the source view.

       backgroundColor
       borderWidth
       borderColor

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

// conditional modifiers
extension HeroModifier {
  /**
   Apply modifiers only if the condition return true.
   */
  public static func when(_ condition: @escaping (HeroConditionalContext) -> Bool, _ modifiers: [HeroModifier]) -> HeroModifier {
    return HeroModifier { targetState in
      if targetState.conditionalModifiers == nil {
        targetState.conditionalModifiers = []
      }
      targetState.conditionalModifiers!.append((condition, modifiers))
    }
  }

  public static func when(_ condition: @escaping (HeroConditionalContext) -> Bool, _ modifiers: HeroModifier...) -> HeroModifier {
    return .when(condition, modifiers)
  }

  public static func whenMatched(_ modifiers: HeroModifier...) -> HeroModifier {
    return .when({ $0.isMatched }, modifiers)
  }

  public static func whenPresenting(_ modifiers: HeroModifier...) -> HeroModifier {
    return .when({ $0.isPresenting }, modifiers)
  }

  public static func whenDismissing(_ modifiers: HeroModifier...) -> HeroModifier {
    return .when({ !$0.isPresenting }, modifiers)
  }

  public static func whenAppearing(_ modifiers: HeroModifier...) -> HeroModifier {
    return .when({ $0.isAppearing }, modifiers)
  }

  public static func whenDisappearing(_ modifiers: HeroModifier...) -> HeroModifier {
    return .when({ !$0.isAppearing }, modifiers)
  }
}

// advance modifiers
extension HeroModifier {
  /**
   Apply modifiers directly to the view at the start of the transition.
   The modifiers supplied here won't be animated.
   For source views, modifiers are set directly at the beginning of the animation.
   For destination views, they replace the target state (final appearance).
   */
  public static func beginWith(_ modifiers: [HeroModifier]) -> HeroModifier {
    return HeroModifier { targetState in
      if targetState.beginState == nil {
        targetState.beginState = []
      }
      targetState.beginState!.append(contentsOf: modifiers)
    }
  }

  public static func beginWith(modifiers: [HeroModifier]) -> HeroModifier {
    return .beginWith(modifiers)
  }

  public static func beginWith(_ modifiers: HeroModifier...) -> HeroModifier {
    return .beginWith(modifiers)
  }

  /**
   Use global coordinate space.
   
   When using global coordinate space. The view become a independent view that is not a subview of any view.
   It won't move when its parent view moves, and won't be affected by parent view's attributes.
   
   When a view is matched, this is automatically enabled.
   The `source` modifier will also enable this.
   
   Global coordinate space is default for all views prior to version 0.1.3
   */
  public static var useGlobalCoordinateSpace: HeroModifier = HeroModifier { targetState in
    targetState.coordinateSpace = .global
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
   Force the view to animate.
   
   By default, Hero will not animate if the view is outside the screen bounds or if there is no animatable hero modifier, unless this modifier is used.
   */
  public static var forceAnimate = HeroModifier { targetState in
    targetState.forceAnimate = true
  }

  /**
   Force Hero use scale based size animation. This will convert all .size modifier into .scale modifier.
   This is to help Hero animate layers that doesn't support bounds animation. Also gives better performance.
   */
  public static var useScaleBasedSizeChange: HeroModifier = HeroModifier { targetState in
    targetState.useScaleBasedSizeChange = true
  }
}
