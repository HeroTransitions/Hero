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

/// Base class for managing a Hero transition
public class HeroBaseController: NSObject {
  // MARK: Properties
  /// context object holding transition informations
  public internal(set) var context: HeroContext!
  /// whether or not we are handling transition interactively
  public var interactive: Bool {
    return displayLink == nil
  }
  /// progress of the current transition. 0 if no transition is happening
  public internal(set) var progress: Double = 0 {
    didSet {
      if transitioning {
        if let progressUpdateObservers = progressUpdateObservers {
          for observer in progressUpdateObservers {
            observer.heroDidUpdateProgress(progress: progress)
          }
        }

        let timePassed = progress * totalDuration
        if interactive {
          for animator in animators {
            animator.seekTo(timePassed: timePassed)
          }
        } else {
          for plugin in plugins {
            if plugin.requirePerFrameCallback {
              plugin.seekTo(timePassed: timePassed)
            }
          }
        }
      }
    }
  }
  /// whether or not we are doing a transition
  public var transitioning: Bool {
    return transitionContainer != nil
  }

  /// container we created to hold all animating views, will be a subview of the
  /// transitionContainer when transitioning
  public internal(set) var container: UIView!

  /// this is the container supplied by UIKit
  internal var transitionContainer: UIView!

  // By default, Hero will always appear to be interactive to UIKit. This forces it to appear non-interactive.
  // Used when doing a hero_replaceViewController within a UINavigationController, to fix a bug with
  // UINavigationController.setViewControllers not able to handle interactive transition
  internal var forceNotInteractive = false

  internal var displayLink: CADisplayLink?
  internal var progressUpdateObservers: [HeroProgressUpdateObserver]?

  /// max duration needed by the default animator and plugins
  public internal(set) var totalDuration: TimeInterval = 0.0

  /// current animation complete duration. 
  /// (differs from totalDuration because this one could be the duration for finishing interactive transition)
  internal var duration: TimeInterval = 0.0
  internal var beginTime: TimeInterval? {
    didSet {
      if beginTime != nil {
        if displayLink == nil {
          displayLink = CADisplayLink(target: self, selector: #selector(displayUpdate(_:)))
          displayLink!.add(to: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        }
      } else {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        displayLink = nil
      }
    }
  }
  func displayUpdate(_ link: CADisplayLink) {
    if transitioning, duration > 0, let beginTime = beginTime {
      let timePassed = CACurrentMediaTime() - beginTime

      if timePassed > duration {
        progress = finishing ? 1 : 0
        self.beginTime = nil
        complete(finished: finishing)
      } else {
        var completed = timePassed / totalDuration
        if !finishing {
          completed = 1 - completed
        }
        completed = max(0, min(1, completed))
        progress = completed
      }
    }
  }


  internal var finishing: Bool = true

  internal var processors: [HeroPreprocessor]!
  internal var animators: [HeroAnimator]!
  internal var plugins: [HeroPlugin]!

  internal static var enabledPlugins: [HeroPlugin.Type] = []

  internal override init() {}
}

public extension HeroBaseController {
  // MARK: Interactive Transition

  /**
   Update the progress for the interactive transition.
   - Parameters:
   - progress: the current progress, must be between 0...1
   */
  public func update(progress: Double) {
    guard transitioning else { return }
    let progress = max(0, min(1, progress))
    beginTime = nil
    self.progress = progress
  }

  /**
   Finish the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **end** state
   */
  public func end(animate: Bool = true) {
    guard transitioning && interactive else { return }
    if !animate {
      complete(finished:true)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:progress * totalDuration, reverse: false))
    }
    complete(after: maxTime, finishing: true)
  }

  /**
   Cancel the interactive transition.
   Will stop the interactive transition and animate from the
   current state to the **begining** state
   */
  public func cancel(animate: Bool = true) {
    guard transitioning && interactive else { return }
    if !animate {
      complete(finished:false)
      return
    }
    var maxTime: TimeInterval = 0
    for animator in animators {
      maxTime = max(maxTime, animator.resume(timePassed:progress * totalDuration, reverse: true))
    }
    complete(after: maxTime, finishing: false)
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
    guard transitioning && interactive else { return }
    let targetState = HeroTargetState(modifiers: modifiers)
    if let otherView = context.pairedView(for: view) {
      for animator in animators {
        animator.apply(state: targetState, to: otherView)
      }
    }
    for animator in animators {
      animator.apply(state: targetState, to: view)
    }
  }
}

public extension HeroBaseController {
  // MARK: Observe Progress

  /**
   Receive callbacks on each animation frame.
   Observers will be cleaned when transition completes

   - Parameters:
   - observer: the observer
   */
  func observeForProgressUpdate(observer: HeroProgressUpdateObserver) {
    if progressUpdateObservers == nil {
      progressUpdateObservers = []
    }
    progressUpdateObservers!.append(observer)
  }
}

// internal methods for transition
internal extension HeroBaseController {
  func complete(after: TimeInterval, finishing: Bool) {
    if after <= 0.001 {
      complete(finished: finishing)
      return
    }
    let timePassed = (finishing ? progress : 1 - progress) * totalDuration
    self.finishing = finishing
    self.duration = after + timePassed
    self.beginTime = CACurrentMediaTime() - timePassed
  }

  func complete(finished: Bool) {
    guard transitioning else { return }
    for animator in animators {
      animator.clean()
    }
    context.unhideAll()

    container.removeFromSuperview()
    transitionContainer!.isUserInteractionEnabled = true

    progressUpdateObservers = nil
    transitionContainer = nil
    container = nil
    processors = nil
    animators = nil
    plugins = nil
    context = nil
    beginTime = nil
    progress = 0
    totalDuration = 0
  }
}

// MARK: Plugin Support
internal extension HeroBaseController {
  static func isEnabled(plugin: HeroPlugin.Type) -> Bool {
    return enabledPlugins.index(where: { return $0 == plugin}) != nil
  }

  static func enable(plugin: HeroPlugin.Type) {
    disable(plugin: plugin)
    enabledPlugins.append(plugin)
  }

  static func disable(plugin: HeroPlugin.Type) {
    if let index = enabledPlugins.index(where: { return $0 == plugin}) {
      enabledPlugins.remove(at: index)
    }
  }
}
