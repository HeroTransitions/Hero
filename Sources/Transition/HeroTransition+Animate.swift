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

extension HeroTransition {
  open func animate() {
    guard state == .starting else { return }
    state = .animating

    if let toView = toView {
      context.unhide(view: toView)
    }

    // auto hide all animated views
    for view in animatingFromViews {
      context.hide(view: view)
    }
    for view in animatingToViews {
      context.hide(view: view)
    }

    var totalDuration: TimeInterval = 0
    var animatorWantsInteractive = false

    if context.insertToViewFirst {
      for v in animatingToViews { _ = context.snapshotView(for: v) }
      for v in animatingFromViews { _ = context.snapshotView(for: v) }
    } else {
      for v in animatingFromViews { _ = context.snapshotView(for: v) }
      for v in animatingToViews { _ = context.snapshotView(for: v) }
    }

    // UIKit appears to set fromView setNeedLayout to be true.
    // We don't want fromView to layout after our animation starts.
    // Therefore we kick off the layout beforehand
    fromView?.layoutIfNeeded()

    for animator in animators {
      let duration = animator.animate(fromViews: animatingFromViews.filter({ animator.canAnimate(view: $0, appearing: false) }),
                                      toViews: animatingToViews.filter({ animator.canAnimate(view: $0, appearing: true) }))
      if duration == .infinity {
        animatorWantsInteractive = true
      } else {
        totalDuration = max(totalDuration, duration)
      }
    }

    self.totalDuration = totalDuration
    if let forceFinishing = forceFinishing {
      complete(finished: forceFinishing)
    } else if let startingProgress = startingProgress {
      update(startingProgress)
    } else if animatorWantsInteractive {
      update(0)
    } else {
      complete(after: totalDuration, finishing: true)
    }

    fullScreenSnapshot?.removeFromSuperview()
  }
}

#endif
