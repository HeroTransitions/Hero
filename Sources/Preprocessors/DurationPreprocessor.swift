//
//  DurationPreprocessor.swift
//  Hero
//
//  Created by Luke on 3/16/17.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit

class DurationPreprocessor: BasePreprocessor {

  override func process(fromViews: [UIView], toViews: [UIView]) {
    var maxDuration: TimeInterval = 0
    maxDuration = applyOptimizedDurationIfNoDuration(views:fromViews)
    maxDuration = max(maxDuration, applyOptimizedDurationIfNoDuration(views:toViews))
    setDurationForInfiniteDuration(views: fromViews, duration: maxDuration)
    setDurationForInfiniteDuration(views: toViews, duration: maxDuration)
  }

  func optimizedDurationFor(view: UIView) -> TimeInterval {
    let targetState = context[view]!
    return view.optimizedDuration(fromPosition: context.container.convert(view.layer.position, from: view.superview),
                                  toPosition: targetState.position,
                                  size: targetState.size,
                                  transform: targetState.transform)
  }

  func applyOptimizedDurationIfNoDuration(views: [UIView]) -> TimeInterval {
    var maxDuration: TimeInterval = 0
    for view in views where context[view] != nil {
      if context[view]?.duration == nil {
        context[view]!.duration = optimizedDurationFor(view: view)
      }
      if context[view]!.duration! == .infinity {
        maxDuration = max(maxDuration, optimizedDurationFor(view: view))
      } else {
        maxDuration = max(maxDuration, context[view]!.duration!)
      }
    }
    return maxDuration
  }

  func setDurationForInfiniteDuration(views: [UIView], duration: TimeInterval) {
    for view in views where context[view]?.duration == .infinity {
      context[view]!.duration = duration
    }
  }
}
