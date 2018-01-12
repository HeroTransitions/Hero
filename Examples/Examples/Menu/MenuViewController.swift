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
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let vc = segue.destination as? MenuPageViewController, let sender = sender as? UIButton {
      sender.hero.id = "selected"
      vc.view.hero.modifiers = [.source(heroID: "selected")]
      vc.centerButton.hero.id = "selected"
      vc.centerButton.hero.modifiers = [.durationMatchLongest]
      vc.view.backgroundColor = sender.backgroundColor
      vc.centerButton.setImage(sender.image(for: .normal), for: .normal)
    }
  }
  
  @objc private func dismissMenu() {
    hero.dismissViewController()
  }
}

class MenuPageViewController: UIViewController {
  @IBOutlet weak var centerButton: UIButton!
}
