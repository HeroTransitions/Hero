//
//  ImageLibrary.swift
//  HeroExamples
//
//  Created by YiLun Zhao on 2017-01-04.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit

class ImageLibrary {
  static var count = 100
  static func thumbnail(index: Int) -> UIImage {
    return UIImage(named: "Unsplash\(index % 11)_thumb")!
  }
  static func image(index: Int) -> UIImage {
    return UIImage(named: "Unsplash\(index % 11)")!
  }
}
