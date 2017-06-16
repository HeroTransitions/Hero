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

public extension Hero {
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

// MARK: Plugin Support
internal extension Hero {
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

internal extension Hero {
  // should call this after `prepareForTransition` & before `processContext`
  func insert<T>(preprocessor: HeroPreprocessor, before: T.Type) {
    let processorIndex = processors.index {
      $0 is T
      } ?? processors.count
    preprocessor.context = context
    processors.insert(preprocessor, at: processorIndex)
  }
}
