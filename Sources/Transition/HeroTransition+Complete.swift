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
  open func complete(finished: Bool) {
    if state == .notified {
      forceFinishing = finished
    }
    guard state == .animating || state == .starting else { return }
    defer {
      transitionContext = nil
      fromViewController = nil
      toViewController = nil
      inNavigationController = false
      inTabBarController = false
      forceNotInteractive = false
      animatingToViews.removeAll()
      animatingFromViews.removeAll()
      progressUpdateObservers = nil
      transitionContainer = nil
      completionCallback = nil
      forceFinishing = nil
      container = nil
      processors.removeAll()
      animators.removeAll()
      plugins.removeAll()
      context = nil
      progress = 0
      totalDuration = 0
      state = .possible
    }
    state = .completing

    progressRunner.stop()
    context.clean()

    if let toView = toView, let fromView = fromView {
      if finished && isPresenting && toOverFullScreen {
        // finished presenting a overFullScreen VC
        context.unhide(rootView: toView)
        context.removeSnapshots(rootView: toView)
        context.storeViewAlpha(rootView: fromView)
        fromViewController?.heroStoredSnapshot = container
        container.superview?.addSubview(fromView)
        fromView.addSubview(container)
      } else if !finished && !isPresenting && fromOverFullScreen {
        // cancelled dismissing a overFullScreen VC
        context.unhide(rootView: fromView)
        context.removeSnapshots(rootView: fromView)
        context.storeViewAlpha(rootView: toView)
        toViewController?.heroStoredSnapshot = container
        container.superview?.addSubview(toView)
        toView.addSubview(container)
      } else {
        context.unhideAll()
        context.removeAllSnapshots()
      }

      // move fromView & toView back from our container back to the one supplied by UIKit
      if (toOverFullScreen && finished) || (fromOverFullScreen && !finished) {
        transitionContainer?.addSubview(finished ? fromView : toView)
      }
      transitionContainer?.addSubview(finished ? toView : fromView)

      if isPresenting != finished, !inContainerController, transitionContext != nil {
        // only happens when present a .overFullScreen VC
        // bug: http://openradar.appspot.com/radar?id=5320103646199808
        UIApplication.shared.keyWindow?.addSubview(isPresenting ? fromView : toView)
      }
    }

    if container.superview == transitionContainer {
      container.removeFromSuperview()
    }

    for animator in animators {
      animator.clean()
    }

    transitionContainer?.isUserInteractionEnabled = true

    completionCallback?(finished)

    if finished {
      if let fvc = fromViewController, let tvc = toViewController {
        closureProcessForHeroDelegate(vc: fvc) {
          $0.heroDidEndAnimatingTo?(viewController: tvc)
          $0.heroDidEndTransition?()
        }

        closureProcessForHeroDelegate(vc: tvc) {
          $0.heroDidEndAnimatingFrom?(viewController: fvc)
          $0.heroDidEndTransition?()
        }
      }
      transitionContext?.finishInteractiveTransition()
    } else {
      if let fvc = fromViewController, let tvc = toViewController {
        closureProcessForHeroDelegate(vc: fvc) {
          $0.heroDidCancelAnimatingTo?(viewController: tvc)
          $0.heroDidCancelTransition?()
        }

        closureProcessForHeroDelegate(vc: tvc) {
          $0.heroDidCancelAnimatingFrom?(viewController: fvc)
          $0.heroDidCancelTransition?()
        }
      }
      transitionContext?.cancelInteractiveTransition()
    }
    transitionContext?.completeTransition(finished)
  }
}
