//
//  SwiftSupport.swift
//  Hero
//
//  Created by Steven Deutsch on 10/14/18.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

#if canImport(UIKit) && !(swift(>=4.2))
import Foundation
import CoreMedia
import CoreGraphics

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

#if canImport(UIKit)
import UIKit

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
#endif

extension RunLoop {
  enum Mode {
		static let common = RunLoopMode.commonModes
  }
}

#endif
