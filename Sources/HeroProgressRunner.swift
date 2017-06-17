//
//  HeroProgressRunner.swift
//  Hero
//
//  Created by Luke on 6/16/17.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import Foundation

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
  internal var displayLink: CADisplayLink?
  internal var isReversed: Bool = false

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

  func start(currentProgress: Double, totalTime: Double, reverse: Bool) {
    stop()
    self.timePassed = currentProgress * totalTime
    self.isReversed = reverse
    self.duration = totalTime
    displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
    displayLink!.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
  }

  func stop() {
    displayLink?.isPaused = true
    displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
    displayLink = nil
  }
}
