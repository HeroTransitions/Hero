//
//  Lexer.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

public enum Token {
  case identifier(String, CountableRange<Int>)
  case number(Float, CountableRange<Int>)
  case parensOpen(CountableRange<Int>)
  case parensClose(CountableRange<Int>)
  case comma(CountableRange<Int>)
  case other(String, CountableRange<Int>)
}

typealias TokenGenerator = (String, CountableRange<Int>) -> Token?
let tokenList: [(String, TokenGenerator)] = [
  ("[ \t\n]", { _ in nil }),
  ("[a-zA-Z][a-zA-Z0-9]*", { .identifier($0, $1) }),
  ("\\-?[0-9.]+", { .number(Float($0)!, $1) }),
  ("\\(", { .parensOpen($1) }),
  ("\\)", { .parensClose($1) }),
  (",", { .comma($1) })
]

public class Lexer {
  let input: String
  public init(input: String) {
    self.input = input
  }
  public func tokenize() -> [Token] {
    var tokens = [Token]()
    var content = input

    while !content.characters.isEmpty {
      var matched = false

      for (pattern, generator) in tokenList {
        if let (m, r) = content.match(regex: pattern) {
          if let t = generator(m, r) {
            tokens.append(t)
          }

          content = content.substring(from: content.index(content.startIndex, offsetBy: m.characters.count))
          matched = true
          break
        }
      }

      if !matched {
        let index = content.index(content.startIndex, offsetBy: 1)
        let intIndex = content.distance(from: content.startIndex, to: index)
        tokens.append(.other(content.substring(to: index), intIndex..<intIndex+1))
        content = content.substring(from: index)
      }
    }
    return tokens
  }
}
