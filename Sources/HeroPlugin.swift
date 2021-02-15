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

#if canImport(UIKit)

import UIKit

open class HeroPlugin: NSObject, HeroPreprocessor, HeroAnimator {

  weak public var hero: HeroTransition!

  public var context: HeroContext! {
    return hero.context
  }

  /**
    Determines whether or not to receive `seekTo` callback on every frame.
   
    Default is false.
   
    When **requirePerFrameCallback** is **false**, the plugin needs to start its own animations inside `animate` & `resume`
    The `seekTo` method is only being called during an interactive transition.
   
    When **requirePerFrameCallback** is **true**, the plugin will receive `seekTo` callback on every animation frame. Hence it is possible for the plugin to do per-frame animations without implementing `animate` & `resume`
   */
  open var requirePerFrameCallback = false

  public override required init() {}

  /**
   Called before any animation.
   Override this method when you want to preprocess modifiers for views
   - Parameters:
       - context: object holding all parsed and changed modifiers,
       - fromViews: A flattened list of all views from source ViewController
       - toViews: A flattened list of all views from destination ViewController

   To check a view's modifiers:

       context[view]
       context[view, "modifierName"]

   To set a view's modifiers:

       context[view] = [("modifier1", ["parameter1"]), ("modifier2", [])]
       context[view, "modifier1"] = ["parameter1", "parameter2"]

  */
  open func process(fromViews: [UIView], toViews: [UIView]) {}

  /**
   - Returns: return true if the plugin can handle animating the view.
   - Parameters:
       - context: object holding all parsed and changed modifiers,
       - view: the view to check whether or not the plugin can handle the animation
       - appearing: true if the view is appearing(i.e. a view in destination ViewController)
   If return true, Hero won't animate and won't let any other plugins animate this view.
   The view will also be hidden automatically during the animation.
   */
  open func canAnimate(view: UIView, appearing: Bool) -> Bool { return false }

  /**
   Perform the animation.

   Note: views in `fromViews` & `toViews` are hidden already. Unhide then if you need to take snapshots.
   - Parameters:
       - context: object holding all parsed and changed modifiers,
       - fromViews: A flattened list of all views from source ViewController (filtered by `canAnimate`)
       - toViews: A flattened list of all views from destination ViewController (filtered by `canAnimate`)
   - Returns: The duration needed to complete the animation
   */

  open func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval { return 0 }

  /**
   Called when all animations are completed.

   Should perform cleanup and release any reference
   */
  open func clean() {}

  /**
   For supporting interactive animation only.

   This method is called when an interactive animation is in place
   The plugin should pause the animation, and seek to the given progress
   - Parameters:
     - timePassed: time of the animation to seek to.
   */
  open func seekTo(timePassed: TimeInterval) {}

  /**
   For supporting interactive animation only.

   This method is called when an interactive animation is ended
   The plugin should resume the animation.
   - Parameters:
   - timePassed: will be the same value since last `seekTo`
   - reverse: a boolean value indicating whether or not the animation should reverse
   */
  open func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval { return 0 }

  /**
   For supporting interactive animation only.

   This method is called when user wants to override animation modifiers during an interactive animation

   - Parameters:
       - state: the target state to override
       - view: the view to override
   */
  open func apply(state: HeroTargetState, to view: UIView) {}
  open func changeTarget(state: HeroTargetState, isDestination: Bool, to view: UIView) {}
}

// methods for enable/disable the current plugin
extension HeroPlugin {
  public static var isEnabled: Bool {
    get {
      return HeroTransition.isEnabled(plugin: self)
    }
    set {
      if newValue {
        enable()
      } else {
        disable()
      }
    }
  }
  public static func enable() {
    HeroTransition.enable(plugin: self)
  }
  public static func disable() {
    HeroTransition.disable(plugin: self)
  }
}

// MARK: Plugin Support
internal extension HeroTransition {
  static func isEnabled(plugin: HeroPlugin.Type) -> Bool {
    return enabledPlugins.firstIndex(where: { return $0 == plugin}) != nil
  }

  static func enable(plugin: HeroPlugin.Type) {
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }

  static func disable(plugin: HeroPlugin.Type) {
    if let index = enabledPlugins.firstIndex(where: { return $0 == plugin}) {
      enabledPlugins.remove(at: index)
    }
  }
}

#endif
