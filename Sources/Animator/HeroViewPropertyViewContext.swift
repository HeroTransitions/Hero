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

@available(iOS 10, tvOS 10, *)
internal class HeroViewPropertyViewContext: HeroAnimatorViewContext {

  var viewPropertyAnimator: UIViewPropertyAnimator!
  var endEffect: UIVisualEffect?
  var startEffect: UIVisualEffect?

  override class func canAnimate(view: UIView, state: HeroTargetState, appearing: Bool) -> Bool {
    return view is UIVisualEffectView && state.opacity != nil
  }

  override func resume(timePassed: TimeInterval, reverse: Bool) -> TimeInterval {
    guard let visualEffectView = snapshot as? UIVisualEffectView else { return .zero }
    guard duration > 0 else { return .zero }
    if reverse {
      viewPropertyAnimator?.stopAnimation(false)
      viewPropertyAnimator?.finishAnimation(at: .current)

      viewPropertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
        visualEffectView.effect = reverse ? self.startEffect : self.endEffect
      }

      // workaround for a bug https://openradar.appspot.com/30856746
      viewPropertyAnimator.startAnimation()
      viewPropertyAnimator.pauseAnimation()

      viewPropertyAnimator.fractionComplete = CGFloat(1.0 - timePassed / duration)
    }

    DispatchQueue.main.async {
      self.viewPropertyAnimator.startAnimation()
    }

    return duration
  }

  override func seek(timePassed: TimeInterval) {
    viewPropertyAnimator?.pauseAnimation()
    viewPropertyAnimator?.fractionComplete = CGFloat(timePassed / duration)
  }

  override func clean() {
    super.clean()
    viewPropertyAnimator?.stopAnimation(false)
    viewPropertyAnimator?.finishAnimation(at: .current)
    viewPropertyAnimator = nil
  }

  override func startAnimations() -> TimeInterval {
    guard let visualEffectView = snapshot as? UIVisualEffectView else { return 0 }
    let appearedEffect = visualEffectView.effect
    let disappearedEffect = targetState.opacity == 0 ? nil : visualEffectView.effect
    startEffect = appearing ? disappearedEffect : appearedEffect
    endEffect = appearing ? appearedEffect : disappearedEffect
    visualEffectView.effect = startEffect
    viewPropertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
      visualEffectView.effect = self.endEffect
    }
    viewPropertyAnimator.startAnimation()
    return duration
  }
}

#endif
