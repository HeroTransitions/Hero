//
//  UIColor+HexString.swift
//  Hero
//
//  Created by Joseph Mattiello on 10/21/19.
//  Copyright © 2019 Luke Zhao. All rights reserved.
//

#if canImport(UIKit)
import UIKit.UIColor

extension UIColor {
  convenience init?(hexString hex: String) {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }

    guard cString.count == 6 else {
      return nil
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}

#endif
