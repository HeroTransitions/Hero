//
//  FirstViewController.swift
//  HeroExamples
//
//  Created by Luke Zhao on 2017-11-04.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

  @IBAction func toggleIsHeroEnabled(_ sender: UISwitch) {

    // uncomment the following code to configure different animation type
    // navigationController?.heroNavigationAnimationType = .zoomOut

    navigationController?.hero.isEnabled = sender.isOn
  }

}
