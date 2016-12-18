//
//  AdvanceLabelViewController.swift
//  HeroExamples
//
//  Created by Luke Zhao on 2016-12-11.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit
import Hero
import ZCAnimatedLabel

class LabelTransformViewController: UIViewController {
  @IBOutlet weak var pluginSwitch: UISwitch!
  @IBAction func togglePlugin(_ sender: UISwitch) {
    if sender.isOn{
      LabelMorphPlugin.enable()
    } else {
      LabelMorphPlugin.disable()
    }
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
