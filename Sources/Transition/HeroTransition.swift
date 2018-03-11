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

/**
 ### The singleton class/object for controlling interactive transitions.

 ```swift
 Hero.shared
 ```

 #### Use the following methods for controlling the interactive transition:

 ```swift
 func update(progress:Double)
 func end()
 func cancel()
 func apply(modifiers:[HeroModifier], to view:UIView)
 ```
 */
public class Hero: NSObject {
  /// Shared singleton object for controlling the transition
  public static var shared = HeroTransition()
}

public protocol HeroTransitionDelegate: class {
  func heroTransition(_ hero: HeroTransition, didUpdate state: HeroTransitionState)
  func heroTransition(_ hero: HeroTransition, didUpdate progress: Double)
}

open class HeroTransition: NSObject {
  public weak var delegate: HeroTransitionDelegate?

  public var defaultAnimation: HeroDefaultAnimationType = .auto
  public var containerColor: UIColor = .black
  public var isUserInteractionEnabled = false
  public var viewOrderingStrategy: HeroViewOrderingStrategy = .auto

  public internal(set) var state: HeroTransitionState = .possible {
    didSet {
      if state != .notified, state != .starting {
        beginCallback?(state == .animating)
        beginCallback = nil
      }
      delegate?.heroTransition(self, didUpdate: state)
    }
  }

  public var isTransitioning: Bool { return state != .possible }
  public internal(set) var isPresenting: Bool = true

  @available(*, deprecated, message: "Use isTransitioning instead")
  public var transitioning: Bool {
    return isTransitioning
  }
  @available(*, deprecated, message: "Use isPresenting instead")
  public var presenting: Bool {
    return isPresenting
  }

  /// container we created to hold all animating views, will be a subview of the
  /// transitionContainer when transitioning
  public internal(set) var container: UIView!

  /// this is the container supplied by UIKit
  internal var transitionContainer: UIView?

  internal var completionCallback: ((Bool) -> Void)?
  internal var beginCallback: ((Bool) -> Void)?

  internal var processors: [HeroPreprocessor] = []
  internal var animators: [HeroAnimator] = []
  internal var plugins: [HeroPlugin] = []
  internal var animatingFromViews: [UIView] = []
  internal var animatingToViews: [UIView] = []
  internal static var enabledPlugins: [HeroPlugin.Type] = []

  /// destination view controller
  public internal(set) var toViewController: UIViewController?
  /// source view controller
  public internal(set) var fromViewController: UIViewController?

  /// context object holding transition informations
  public internal(set) var context: HeroContext!

  /// whether or not we are handling transition interactively
  public var interactive: Bool {
    return !progressRunner.isRunning
  }

  internal var progressUpdateObservers: [HeroProgressUpdateObserver]?

  /// max duration needed by the animators
  public internal(set) var totalDuration: TimeInterval = 0.0

  /// progress of the current transition. 0 if no transition is happening
  public internal(set) var progress: Double = 0 {
    didSet {
      if state == .animating {
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
          for plugin in plugins where plugin.requirePerFrameCallback {
            plugin.seekTo(timePassed: timePassed)
          }
        }

        transitionContext?.updateInteractiveTransition(CGFloat(progress))
      }
      delegate?.heroTransition(self, didUpdate: progress)
    }
  }
  lazy var progressRunner: HeroProgressRunner = {
    let runner = HeroProgressRunner()
    runner.delegate = self
    return runner
  }()

  /// a UIViewControllerContextTransitioning object provided by UIKit,
  /// might be nil when transitioning. This happens when calling heroReplaceViewController
  internal weak var transitionContext: UIViewControllerContextTransitioning?

  internal var fullScreenSnapshot: UIView?

  // By default, Hero will always appear to be interactive to UIKit. This forces it to appear non-interactive.
  // Used when doing a hero_replaceViewController within a UINavigationController, to fix a bug with
  // UINavigationController.setViewControllers not able to handle interactive transition
  internal var forceNotInteractive = false
  internal var forceFinishing: Bool?
  internal var startingProgress: CGFloat?

  internal var inNavigationController = false
  internal var inTabBarController = false
  internal var inContainerController: Bool {
    return inNavigationController || inTabBarController
  }
  internal var toOverFullScreen: Bool {
    return !inContainerController && (toViewController?.modalPresentationStyle == .overFullScreen || toViewController?.modalPresentationStyle == .overCurrentContext)
  }
  internal var fromOverFullScreen: Bool {
    return !inContainerController && (fromViewController?.modalPresentationStyle == .overFullScreen || fromViewController?.modalPresentationStyle == .overCurrentContext)
  }

  internal var toView: UIView? { return toViewController?.view }
  internal var fromView: UIView? { return fromViewController?.view }

  public override init() { super.init() }

  func complete(after: TimeInterval, finishing: Bool) {
    guard [HeroTransitionState.animating, .starting, .notified].contains(state) else { return }
    if after <= 1.0 / 120 {
      complete(finished: finishing)
      return
    }
    let totalTime: TimeInterval
    if finishing {
      totalTime = after / max((1 - progress), 0.01)
    } else {
      totalTime = after / max(progress, 0.01)
    }
    progressRunner.start(timePassed: progress * totalTime, totalTime: totalTime, reverse: !finishing)
  }

  // MARK: Observe Progress

  /**
   Receive callbacks on each animation frame.
   Observers will be cleaned when transition completes

   - Parameters:
   - observer: the observer
   */
  public func observeForProgressUpdate(observer: HeroProgressUpdateObserver) {
    if progressUpdateObservers == nil {
      progressUpdateObservers = []
    }
    progressUpdateObservers!.append(observer)
  }
}

extension HeroTransition: HeroProgressRunnerDelegate {
  func updateProgress(progress: Double) {
    self.progress = progress
  }
}
