//
//  LiveInjection1ViewController.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2017-01-04.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class LiveInjection1ViewController: UIViewController {
  
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var blueView: UIView!
  
}

extension LiveInjection1ViewController:HeroViewControllerDelegate{
  func heroWillStartTransition() {
    textLabel.heroModifiers = [.translate(x:500)]
    blueView.heroID = "blue"
    blueView.heroModifiers = [.zPosition(5)]
  }
}
