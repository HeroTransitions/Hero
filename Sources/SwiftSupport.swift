//
//  SwiftSupport.swift
//  Hero
//
//  Created by Steven Deutsch on 10/14/18.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

#if !(swift(>=4.2))
import Foundation
import CoreMedia
import CoreGraphics
import UIKit

extension CMTime {
  static let zero = kCMTimeZero
}

enum CAMediaTimingFillMode {
  static let both = kCAFillModeBoth
}

enum CAMediaTimingFunctionName {
  static let linear = kCAMediaTimingFunctionLinear
  static let easeIn = kCAMediaTimingFunctionEaseIn
  static let easeOut = kCAMediaTimingFunctionEaseOut
  static let easeInEaseOut = kCAMediaTimingFunctionEaseInEaseOut
}

extension UIControl {
  typealias State = UIControlState
}

public extension UINavigationController {
  typealias Operation = UINavigationControllerOperation
}

extension UIViewController {
  var children: [UIViewController] {
    return childViewControllers
  }
}

extension RunLoop {
  enum Mode {
    static let common = RunLoopMode.commonModes
  }
}
#endif
