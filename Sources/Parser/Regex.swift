//
//  Regex.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

var expressions = [String: NSRegularExpression]()
public extension String {
  func match(regex: String) -> (String, CountableRange<Int>)? {
    let expression: NSRegularExpression
    if let exists = expressions[regex] {
      expression = exists
    } else {
      do {
        expression = try NSRegularExpression(pattern: "^\(regex)", options: [])
        expressions[regex] = expression
      } catch {
        return nil
      }
    }

    let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSRange(0 ..< self.utf16.count))
    if range.location != NSNotFound {
      return ((self as NSString).substring(with: range), range.location ..< range.location + range.length )
    }
    return nil
  }
}
