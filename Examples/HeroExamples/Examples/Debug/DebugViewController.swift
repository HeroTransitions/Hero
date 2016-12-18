//
//  DebugViewController.swift
//  HeroExamples
//
//  Created by Luke Zhao on 2016-12-13.
//  Copyright © 2016 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class DebugViewController: UIViewController {
  @IBOutlet weak var pluginSwitch: UISwitch!
  @IBAction func togglePlugin(_ sender: UISwitch) {
    if sender.isOn{
      HeroDebugPlugin.enable()
    } else {
      HeroDebugPlugin.disable()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pluginSwitch.isOn = HeroDebugPlugin.isEnabled
  }
}
