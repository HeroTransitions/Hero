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

public class HeroDefaultAnimator: HeroAnimator {
  weak public var context: HeroContext!
  var viewContexts: [UIView: HeroDefaultAnimatorViewContext] = [:]

  public func seekTo(timePassed: TimeInterval) {
    for viewContext in viewContexts.values {
      viewContext.seek(timePassed: timePassed)
    }
  }

  public func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval {
    var duration: TimeInterval = 0
    for (_, context) in viewContexts {
      context.resume(timePassed: timePassed, reverse: reverse)
      duration = max(duration, context.duration)
    }
    return duration
  }

  public func apply(state: HeroTargetState, to view: UIView) {
    if let context = viewContexts[view] {
      context.apply(state:state)
    }
  }

  public func canAnimate(view: UIView, appearing: Bool) -> Bool {
    guard let state = context[view] else { return false }
    return  state.position != nil ||
            state.size != nil ||
            state.transform != nil ||
            state.cornerRadius != nil ||
            state.opacity != nil ||
            state.overlay != nil ||
            state.borderColor != nil ||
            state.borderWidth != nil ||
            state.shadowOpacity != nil ||
            state.shadowRadius != nil ||
            state.shadowOffset != nil ||
            state.shadowColor != nil ||
            state.shadowPath != nil
  }

  public func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval {
    var duration: TimeInterval = 0

    // animate
    for v in fromViews { animate(view: v, appearing: false) }
    for v in toViews { animate(view: v, appearing: true) }

    // infinite duration means matching the duration of the longest animation
    var infiniteDurationViewContexts = [HeroDefaultAnimatorViewContext]()
    for viewContext in viewContexts.values {
      if viewContext.duration == .infinity {
        infiniteDurationViewContexts.append(viewContext)
      } else {
        duration = max(duration, viewContext.duration)
      }
    }

    for viewContexts in infiniteDurationViewContexts {
      duration = max(duration, viewContexts.optimizedDurationAndTimingFunction().duration)
    }

    for viewContexts in infiniteDurationViewContexts {
      viewContexts.apply(state: [.duration(duration)])
    }

    return duration
  }

  func animate(view: UIView, appearing: Bool) {
    let snapshot = context.snapshotView(for: view)
    let viewContext = HeroDefaultAnimatorViewContext(animator:self, snapshot: snapshot, targetState: context[view]!, appearing: appearing)
    viewContexts[view] = viewContext
  }

  public func clean() {
    for vc in viewContexts.values {
      vc.clean()
    }
    viewContexts.removeAll()
  }
}
