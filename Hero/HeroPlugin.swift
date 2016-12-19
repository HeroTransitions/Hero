//
//  HeroPlugin.swift
//  Pods
//
//  Created by YiLun Zhao on 2016-12-12.
//
//

import UIKit

open class HeroPlugin: HeroPreprocessor, HeroAnimator{
  public required init(){}
  
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
  open func process(context:HeroContext, fromViews:[UIView], toViews:[UIView]){}
  
  /**
   - Returns: return true if the plugin can handle animating the view.
   - Parameters:
       - context: object holding all parsed and changed modifiers,
       - view: the view to check whether or not the plugin can handle the animation
       - appearing: true if the view is appearing(i.e. a view in destination ViewController)
   If return true, Hero won't animate and won't let any other plugins animate this view.
   The view will also be hidden automatically during the animation.
   */
  open func canAnimate(context:HeroContext, view:UIView, appearing:Bool) -> Bool { return false }
  
  /**
   Perform the animation.
   
   Note: views in `fromViews` & `toViews` are hidden already. Unhide then if you need to take snapshots.
   - Parameters:
       - context: object holding all parsed and changed modifiers,
       - fromViews: A flattened list of all views from source ViewController (filtered by `canAnimate`)
       - toViews: A flattened list of all views from destination ViewController (filtered by `canAnimate`)
   - Returns: The duration needed to complete the animation
   */
  open func animate(context:HeroContext, fromViews:[UIView], toViews:[UIView]) -> TimeInterval { return 0 }
  
  
  /**
   Called when all animations are completed.
   
   Should perform cleanup and release any reference
   */
  open func clean(){}
  
  
  /**
   For supporting interactive animation only.
   
   This method is called when an interactive animation is in place
   The plugin should pause the animation, and seek to the given progress
   - Parameters:
     - progress: 0 to 1 Double, progress of the animation
   */
  open func seekTo(progress:Double){}
  
  /**
   For supporting interactive animation only.
   
   This method is called when an interactive animation is ended
   The plugin should pause the animation, and seek to the given progress
   - Parameters:
   - progress: 0 to 1 Double, progress of the animation
   */
  open func resume(from progress:Double, reverse:Bool) -> TimeInterval { return 0 }
  
  /**
   For supporting interactive animation only.
   
   This method is called when user wants to override animation modifiers during an interactive animation
   
   - Parameters:
       - view: the view to override
       - modifiers: the modifiers user want to override to
   */
  open func temporarilySet(view:UIView, to modifiers:HeroModifiers){}

  /**
   Plugin which wants to handle the transition interactively should return true.
   And also keep a reference to the context object to control the transition.
   - Returns: true if the plugin wants interacive start.
   - Parameters:
       - context: object which the plugin can use to control the interactive transition
   */
  open func wantInteractiveHeroTransition(context:HeroInteractiveContext) -> Bool { return false }
}

// methods for enable/disable the current plugin
extension HeroPlugin{
  public static var isEnabled:Bool{
    get{
      return Hero.isEnabled(plugin: self)
    }
    set{
      if newValue {
        enable()
      } else {
        disable()
      }
    }
  }
  public static func enable(){
    Hero.enable(plugin: self)
  }
  public static func disable(){
    Hero.disable(plugin: self)
  }
}
