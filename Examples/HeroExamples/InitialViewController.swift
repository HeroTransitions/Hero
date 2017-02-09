//
//  InitialViewController.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2017-01-01.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit

class InitialViewController: UITableViewController {

  var storyboards: [[String]] = [
    [],
    ["Basic", "MusicPlayer", "Menu", "VideoPlayer"],
    ["CityGuide", "ImageViewer", "VideoPlayer"],
    ["AppleHomePage", "ListToGrid", "ImageGallery"]
  ]

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomLayoutGuide.length, right: 0)
    tableView.scrollIndicatorInsets = tableView.contentInset
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.item < storyboards[indexPath.section].count {
      let storyboardName = storyboards[indexPath.section][indexPath.item]
      let vc = viewController(forStoryboardName: storyboardName)
      present(vc, animated: true, completion: nil)
    }
  }
}
