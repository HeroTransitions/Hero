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
//

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
