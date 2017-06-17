//
//  Hero+Interactive.swift
//  Hero
//
//  Created by Luke on 6/16/17.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import Foundation

extension Hero {
  /**
   Update the progress for the interactive transition.
   - Parameters:
   - progress: the current progress, must be between -1...1
   */
  public func update(_ percentageComplete: CGFloat) {
    guard transitioning else { return }
    self.progressRunner.stop()
    self.progress = max(-1, min(1, Double(percentageComplete)))
  }

  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func finish(animate: Bool = true) {
    guard transitioning else { return }
    if !animate {
      self.complete(finished:true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      maxTime = max(maxTime, animator.resume(timePassed:self.progress * self.totalDuration,
                                             reverse: false))
    }
    self.complete(after: maxTime, finishing: true)
  }

  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **begining** state
   */
  public func cancel(animate: Bool = true) {
    guard transitioning else { return }
    if !animate {
      self.complete(finished:false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      var adjustedProgress = self.progress
      if adjustedProgress < 0 {
        adjustedProgress = -adjustedProgress
      }
      maxTime = max(maxTime, animator.resume(timePassed:adjustedProgress * self.totalDuration,
                                             reverse: true))
    }
    self.complete(after: maxTime, finishing: false)
  }

  /**
   Override modifiers during an interactive animation.

   For example:

   Hero.shared.apply([.position(x:50, y:50)], to:view)

   will set the view's position to 50, 50
   - Parameters:
   - modifiers: the modifiers to override
   - view: the view to override to
   */
  public func apply(modifiers: [HeroModifier], to view: UIView) {
    guard transitioning else { return }
    let targetState = HeroTargetState(modifiers: modifiers)
    if let otherView = self.context.pairedView(for: view) {
      for animator in self.animators {
        animator.apply(state: targetState, to: otherView)
      }
    }
    for animator in self.animators {
      animator.apply(state: targetState, to: view)
    }
  }
}
