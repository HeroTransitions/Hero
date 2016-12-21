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

class LabelTransformViewController: UIViewController {
  @IBOutlet weak var pluginSwitch: UISwitch!
  @IBAction func togglePlugin(_ sender: UISwitch) {
    LabelMorphPlugin.isEnabled = sender.isOn
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pluginSwitch.isOn = LabelMorphPlugin.isEnabled
  }
}

class LabelMorphPlugin:HeroPlugin{
  var morphingLabels:[ZCAnimatedLabel]!

  override func canAnimate(context:HeroContext, view:UIView, appearing:Bool) -> Bool {
    // Here we are animating all UILabels that are not paired.
    // For a real plugin, it should check for whether or not a modifier exist
    // for the view by:
    //     return context[view, "labelMorph"] != nil
    return (view as? UILabel != nil) && context.pairedView(for: view) == nil
  }

  func createMorphingLabel(context:HeroContext, label:UILabel, appearing:Bool) {
    let frame = context.container.convert(label.bounds, from: label)
    let morphingLabel = ZCShapeshiftLabel(frame: frame)
    
    morphingLabel.font = label.font
    morphingLabel.textColor = label.textColor
    morphingLabel.animationDuration = 0.4
    morphingLabel.animationDelay = 0.02
    morphingLabel.zPosition = label.zPosition
    morphingLabel.attributedString = label.attributedText

    morphingLabels.append(morphingLabel)
    context.container.addSubview(morphingLabel)
    
    if appearing{
      morphingLabel.startAppearAnimation()
    } else {
      morphingLabel.startDisappearAnimation()
    }
  }

  override func animate(context:HeroContext, fromViews:[UIView], toViews:[UIView]) -> TimeInterval {
    morphingLabels = []
    var maxDuration:TimeInterval = 0
    
    for view in toViews{
      createMorphingLabel(context: context, label: view as! UILabel, appearing: true)
    }
    for view in fromViews{
      createMorphingLabel(context: context, label: view as! UILabel, appearing: false)
    }
    
    for label in morphingLabels{
      maxDuration = max(maxDuration, TimeInterval(label.totoalAnimationDuration))
    }
    
    return maxDuration
  }

  override func clean(){
    for label in morphingLabels{
      label.stopAnimation()
      label.removeFromSuperview()
    }
    morphingLabels = nil
  }
}
