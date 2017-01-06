//
//  LiveInjection2ViewController.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2017-01-04.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class LiveInjection2ViewController: UIViewController {

  @IBOutlet weak var orangeView: UIView!
  @IBOutlet weak var greenView: UIView!
  @IBOutlet weak var blueView: UIView!

}

extension LiveInjection2ViewController:HeroViewControllerDelegate{

  func heroWillStartTransition() {
    orangeView.heroID = "orange"
    orangeView.heroModifiers = [.scale(x:0.5, y:0.5)]
    greenView.heroID = "green"
    greenView.heroModifiers = [.scale(x:0.5, y:0.5)]
    blueView.heroID = "blue"
    blueView.heroModifiers = [.zPosition(5)]
  }

}
