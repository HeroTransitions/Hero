//
//  Locale+Hero.swift
//  Hero
//
//  Created by Joseph Mattiello on 4/25/20.
//  Copyright © 2020 Luke Zhao. All rights reserved.
//

import Foundation

internal extension Locale {
  static var isDeviceLanguageRightToLeft: Bool {
    let currentLocale: Locale = Locale.current
    guard let code: String = currentLocale.languageCode else {
      return false
    }
    let direction: Locale.LanguageDirection = Locale.characterDirection(forLanguage: code)
    return (direction == .rightToLeft)
  }

  static var isDeviceLanguageLeftToRight: Bool {
    return !isDeviceLanguageRightToLeft
  }
}
