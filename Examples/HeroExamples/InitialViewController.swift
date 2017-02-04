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
    ["Basic", "MusicPlayer", "Menu"],
    ["CityGuide", "ImageViewer", "AppleHomePage", "ListToGrid", "ImageGallery"],
    ["LiveInjection", "Debug", "LabelMorph"]
  ]

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.item < storyboards[indexPath.section].count {
      let storyboardName = storyboards[indexPath.section][indexPath.item]
      let vc = viewController(forStoryboardName: storyboardName)
      present(vc, animated: true, completion: nil)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("viewWillAppear")
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    print("viewDidAppear")
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    print("viewWillDisappear")
    super.viewWillDisappear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("viewDidDisappear")
    super.viewDidDisappear(animated)
  }
}
