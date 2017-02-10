//
//  AnimationSelectTableViewController.swift
//  HeroExamples
//
//  Created by Luke Zhao on 2017-02-10.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit
import Hero

class AnimationSelectTableViewController: UITableViewController {

  var animations: [HeroDefaultAnimationType] = [
    .auto,
    .pushLeft,
    .pushRight,
    .pullLeft,
    .pullRight,
    .slideLeft,
    .slideRight,
    .coverLeft,
    .coverRight,
    .coverUp,
    .coverDown,
    .fade
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : animations.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
    cell.textLabel?.text = animations[indexPath.item].label
    return cell
  }

  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 0 ? nil : indexPath
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = self.storyboard!.instantiateViewController(withIdentifier: "animationSelect")
    Hero.shared.setDefaultAnimationForNextTransition(animations[indexPath.item])
    show(vc, sender: nil)
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 0 ? 300 : 44
  }
}
