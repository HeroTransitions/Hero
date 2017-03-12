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

internal class HeroAnimatorViewContext {
  var animator: HeroAnimator?
  var snapshot: UIView
  var duration: TimeInterval = 0

  var targetState: HeroTargetState

  // computed
  var currentTime: TimeInterval {
    return snapshot.layer.convertTime(CACurrentMediaTime(), from: nil)
  }
  var container: UIView? {
    return animator?.context.container
  }

  class func canAnimate(view: UIView, state: HeroTargetState, appearing: Bool) -> Bool {
    return false
  }

  func apply(state: HeroTargetState) {
  }

  func resume(timePassed: TimeInterval, reverse: Bool) {
  }

  func seek(timePassed: TimeInterval) {
  }

  func clean() {
    animator = nil
  }

  func startAnimations(appearing: Bool) {
  }

  required init(animator: HeroAnimator, snapshot: UIView, targetState: HeroTargetState) {
    self.animator = animator
    self.snapshot = snapshot
    self.targetState = targetState
  }
}
