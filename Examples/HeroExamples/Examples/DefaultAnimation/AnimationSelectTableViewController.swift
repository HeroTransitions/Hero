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

  var animations: [HeroAnimationType] = [
    .push(direction: .left),
    .pull(direction: .left),
    .slide(direction: .left),
    .zoomSlide(direction: .left),
    .cover(direction: .up),
    .uncover(direction: .up),
    .pageIn(direction: .left),
    .pageOut(direction: .left),
    .fade,
    .none
  ]

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

    // the following two lines configures the animation. default is .auto
    Hero.shared.setDefaultAnimationForNextTransition(animations[indexPath.item])
    Hero.shared.setContainerColorForNextTransition(.lightGray)


    hero_replaceViewController(with: vc)
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 0 ? 300 : 44
  }
}
