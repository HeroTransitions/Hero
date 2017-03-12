//
//  MenuViewController.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2017-02-09.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class MenuViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hero_dismissViewController)))
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? MenuPageViewController, let sender = sender as? UIButton {
      sender.heroID = "selected"
      vc.view.heroModifiers = [.source(heroID: "selected")]
      vc.centerButton.heroID = "selected"
      vc.centerButton.heroModifiers = [.durationMatchLongest]
      vc.view.backgroundColor = sender.backgroundColor
      vc.centerButton.setImage(sender.image(for: .normal), for: .normal)
    }
  }
}

class MenuPageViewController: UIViewController {
  @IBOutlet weak var centerButton: UIButton!
}
