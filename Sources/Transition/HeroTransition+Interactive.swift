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

extension HeroTransition {
  /**
   Update the progress for the interactive transition.
   - Parameters:
   - progress: the current progress, must be between 0...1
   */
  public func update(_ percentageComplete: CGFloat) {
    guard state == .animating else {
      startingProgress = percentageComplete
      return
    }
    self.progressRunner.stop()
    self.progress = Double(percentageComplete.clamp(0, 1))
  }

  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func finish(animate: Bool = true) {
    guard state == .animating || state == .notified || state == .starting else { return }
    if !animate {
      self.complete(finished: true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      maxTime = max(maxTime, animator.resume(timePassed: self.progress * self.totalDuration,
                                             reverse: false))
    }
    self.complete(after: maxTime, finishing: true)
  }

  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **beginning** state
   */
  public func cancel(animate: Bool = true) {
    guard state == .animating || state == .notified || state == .starting else { return }
    if !animate {
      self.complete(finished: false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in self.animators {
      var adjustedProgress = self.progress
      if adjustedProgress < 0 {
        adjustedProgress = -adjustedProgress
      }
      maxTime = max(maxTime, animator.resume(timePassed: adjustedProgress * self.totalDuration,
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
    guard state == .animating else { return }
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
