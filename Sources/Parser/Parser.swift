//
//  Parser.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

public enum ParseError: Error {
  case unexpectToken
  case undefinedOperator(String)

  case expectCharacter(Character)
  case expectExpression
  case expectArgumentList
  case expectFunctionName
}

public class Parser {
  let tokens: [Token]
  var index = 0

  public init(tokens: [Token]) {
    self.tokens = tokens
  }

  func peekCurrentToken() -> Token {
    if index >= tokens.count {
      return .other("", 0..<0)
    }
    return tokens[index]
  }

  @discardableResult func popCurrentToken() -> Token {
    defer { index += 1 }
    return tokens[index]
  }

  func parseNumber() throws -> ExprNode {
    guard case let .number(value, _) = popCurrentToken() else {
      throw ParseError.unexpectToken
    }
    return NumberNode(value: value)
  }

  func parseExpression() throws -> ExprNode {
    let node = try parsePrimary()
    return try parseBinaryOp(node: node)
  }

  func parseParens() throws -> ExprNode {
    guard case .parensOpen = popCurrentToken() else {
      throw ParseError.expectCharacter("(")
    }

    let exp = try parseExpression()

    guard case .parensClose = popCurrentToken() else {
      throw ParseError.expectCharacter(")")
    }

    return exp
  }

  func parseIdentifier() throws -> ExprNode {
    guard case let .identifier(name, _) = popCurrentToken() else {
      throw ParseError.unexpectToken
    }

    guard case .parensOpen = peekCurrentToken() else {
      return VariableNode(name: name)
    }
    popCurrentToken()

    var arguments = [ExprNode]()
    if case .parensClose = peekCurrentToken() {
    } else {
      while true {
        let argument = try parseExpression()
        arguments.append(argument)

        if case .parensClose = peekCurrentToken() {
          break
        }

        guard case .comma = popCurrentToken() else {
          throw ParseError.expectArgumentList
        }
      }
    }

    popCurrentToken()
    return CallNode(name: name, arguments: arguments)
  }

  func parsePrimary() throws -> ExprNode {
    switch peekCurrentToken() {
    case .identifier:
      return try parseIdentifier()
    case .number:
      return try parseNumber()
    case .parensOpen:
      return try parseParens()
    default:
      throw ParseError.expectExpression
    }
  }

  let operatorPrecedence: [String: Int] = [
    "+": 20,
    "-": 20,
    "*": 40,
    "/": 40
  ]

  func getCurrentTokenPrecedence() throws -> Int {
    guard index < tokens.count else {
      return -1
    }

    guard case let .other(op, _) = peekCurrentToken() else {
      return -1
    }

    guard let precedence = operatorPrecedence[op] else {
      throw ParseError.undefinedOperator(op)
    }

    return precedence
  }

  func parseBinaryOp(node: ExprNode, exprPrecedence: Int = 0) throws -> ExprNode {
    var lhs = node
    while true {
      let tokenPrecedence = try getCurrentTokenPrecedence()
      if tokenPrecedence < exprPrecedence {
        return lhs
      }

      guard case let .other(op, _) = popCurrentToken() else {
        throw ParseError.unexpectToken
      }

      var rhs = try parsePrimary()
      let nextPrecedence = try getCurrentTokenPrecedence()

      if tokenPrecedence < nextPrecedence {
        rhs = try parseBinaryOp(node: rhs, exprPrecedence: tokenPrecedence+1)
      }
      lhs = BinaryOpNode(name: op, lhs: lhs, rhs: rhs)
    }
  }

  public func parse() throws -> [ExprNode] {
    index = 0

    var nodes = [ExprNode]()
    while index < tokens.count {
      let expr = try parsePrimary()
      nodes.append(expr)
    }

    return nodes
  }
}
