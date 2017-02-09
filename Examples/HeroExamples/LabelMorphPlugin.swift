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
import Hero
import ZCAnimatedLabel

extension HeroModifier {
  public static func labelMorph(type: LabelMorphPlugin.LabelMorphType) -> HeroModifier {
    return HeroModifier { targetState in
      targetState["labelMorph"] = type
    }
  }
}

public class LabelMorphPlugin: HeroPlugin {
  var morphingLabels: [ZCAnimatedLabel]!
  public enum LabelMorphType {
    case fall
    case duang
    case flyin
    case focus
    case shapeshift
    case reveal
    case thrown
    case transparency
    case spin
    case dash
    func createLabel() -> ZCAnimatedLabel {
      switch self {
      case .fall:
        return ZCFallLabel()
      case .duang:
        return ZCDuangLabel()
      case .flyin:
        return ZCFlyinLabel()
      case .focus:
        return ZCFocusLabel()
      case .shapeshift:
        return ZCShapeshiftLabel()
      case .reveal:
        return ZCRevealLabel()
      case .thrown:
        return ZCThrownLabel()
      case .transparency:
        return ZCTransparencyLabel()
      case .spin:
        return ZCSpinLabel()
      case .dash:
        return ZCDashLabel()
      }
    }
  }

  public override func canAnimate(view: UIView, appearing: Bool) -> Bool {
    return view is UILabel

    // Normally, a plugin should check for a specific modifier is used by checking the HeroTargetState.
    // But here we just force every UILabel to be morphed
    // return (context[view]?["labelMorph"] as? LabelMorphType) != nil
  }

  func createMorphingLabel(label: UIView, appearing: Bool) {
    guard let label = label as? UILabel else { return }
    let frame = context.container.convert(label.bounds, from: label)

    let morphingLabel = (context[label]?["labelMorph"] as? LabelMorphType ?? .duang).createLabel()
    morphingLabel.frame = frame
    morphingLabel.font = label.font
    morphingLabel.textColor = label.textColor
    morphingLabel.animationDuration = 0.4
    morphingLabel.animationDelay = 0.02
    morphingLabel.attributedString = label.attributedText
    morphingLabel.clipsToBounds = false

    morphingLabels.append(morphingLabel)
    context.container.addSubview(morphingLabel)

    if appearing {
      morphingLabel.startAppearAnimation()
    } else {
      morphingLabel.startDisappearAnimation()
    }
  }

  public override func animate(fromViews: [UIView], toViews: [UIView]) -> TimeInterval {
    morphingLabels = []
    var maxDuration: TimeInterval = 0

    for view in toViews {
      createMorphingLabel(label: view, appearing: true)
    }
    for view in fromViews {
      createMorphingLabel(label: view, appearing: false)
    }

    for label in morphingLabels {
      maxDuration = max(maxDuration, TimeInterval(label.totoalAnimationDuration))
    }

    return maxDuration
  }

  public override func clean() {
    for label in morphingLabels {
      label.stopAnimation()
      label.removeFromSuperview()
    }
    morphingLabels = nil
  }
}
