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
import QuartzCore

protocol HeroProgressRunnerDelegate: class {
  func updateProgress(progress: Double)
  func complete(finished: Bool)
}

class HeroProgressRunner {
  weak var delegate: HeroProgressRunnerDelegate?

  var isRunning: Bool {
    return displayLink != nil
  }
  internal var timePassed: TimeInterval = 0.0
  internal var duration: TimeInterval = 0.0
    internal var isReversed: Bool = false

  internal var displayLink: CADisplayLink?

  @objc func displayUpdate(_ link: CADisplayLink) {
    timePassed += isReversed ? -link.duration : link.duration
    if isReversed, timePassed <= 1.0 / 120 {
      delegate?.complete(finished: false)
      stop()
      return
    }

    if !isReversed, timePassed > duration - 1.0 / 120 {
      delegate?.complete(finished: true)
      stop()
      return
    }

    delegate?.updateProgress(progress: timePassed / duration)
  }

  func start(timePassed: TimeInterval, totalTime: TimeInterval, reverse: Bool) {
    stop()
    self.timePassed = timePassed
    self.isReversed = reverse
    self.duration = totalTime
    displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
    displayLink!.add(to: .main, forMode: RunLoop.Mode.common)
  }

  func stop() {
    displayLink?.isPaused = true
    displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
    displayLink = nil
  }
}

#endif
