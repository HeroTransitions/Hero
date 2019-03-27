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
  static let zero = CMTime.zero
}

enum CAMediaTimingFillMode {
  static let both = convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.both)
}

enum CAMediaTimingFunctionName {
  static let linear = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.linear)
  static let easeIn = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeIn)
  static let easeOut = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeOut)
  static let easeInEaseOut = convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeInEaseOut)
}

extension UIControl {
  typealias State = UIControlState
}

public extension UINavigationController {
  typealias Operation = UINavigationControllerOperation
}

extension UIViewController {
  var children: [UIViewController] {
    return children
  }
}

extension RunLoop {
  enum Mode {
    static let common = RunLoop.Mode.common
  }
}
#endif




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFillMode(_ input: CAMediaTimingFillMode) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFunctionName(_ input: CAMediaTimingFunctionName) -> String {
	return input.rawValue
}
