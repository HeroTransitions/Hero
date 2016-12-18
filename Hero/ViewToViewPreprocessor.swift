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

public class ViewToViewPreprocessor:HeroPreprocessor {
  public func process(context:HeroContext, fromViews:[UIView], toViews:[UIView]) {
    for tv in toViews{
      guard let id = tv.heroID, let fv = context.sourceView(for: id) else { continue }
      context[fv, "matchedHeroID"] = []
      context[tv, "matchedHeroID"] = []
      
      // viewToView effect is basically sourceID effect applied to both view
      context[tv, "sourceID"] = [id]
      context[fv, "sourceID"] = [id]
      
      let tvZPos = context[tv, "zPositionIfMatched"]?.getCGFloat(0)
      let fvZPos = context[fv, "zPositionIfMatched"]?.getCGFloat(0)
      if let tvZPos = tvZPos{
        context[tv, "zPosition"] = ["\(tvZPos)"]
        context[fv, "zPosition"] = ["\(fvZPos ?? tvZPos)"]
      } else if let fvZPos = fvZPos{
        context[tv, "zPosition"] = ["\(fvZPos)"]
        context[fv, "zPosition"] = ["\(fvZPos)"]
      }
      
      context[tv, "fade"] = []
      if let _ = fv as? UILabel, !fv.isOpaque{
        // cross fade if toView is a label
        context[fv, "fade"] = []
      } else {
        context[fv, "fade"] = nil
      }
    }
  }
}
