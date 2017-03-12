//
//  Nodes.swift
//  Kaleidoscope
//
//  Created by Matthew Cheok on 15/11/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

import Foundation

public class ExprNode: CustomStringConvertible, Equatable {
  public var range: CountableRange<Int> = 0..<0
  public let name: String
  public var description: String {
    return "ExprNode(name: \"\(name)\")"
  }
  public init(name: String) {
    self.name = name
  }
}

public func == (lhs: ExprNode, rhs: ExprNode) -> Bool {
  return lhs.description == rhs.description
}

public class NumberNode: ExprNode {
  public let value: Float
  public override var description: String {
    return "NumberNode(value: \(value))"
  }
  public init(value: Float) {
    self.value = value
    super.init(name: "\(value)")
  }
}

public class VariableNode: ExprNode {
  public override var description: String {
    return "VariableNode(name: \"\(name)\")"
  }
}

public class BinaryOpNode: ExprNode {
  public let lhs: ExprNode
  public let rhs: ExprNode
  public override var description: String {
    return "BinaryOpNode(name: \"\(name)\", lhs: \(lhs), rhs: \(rhs))"
  }
  public init(name: String, lhs: ExprNode, rhs: ExprNode) {
    self.lhs = lhs
    self.rhs = rhs
    super.init(name: "\(name)")
  }
}

public class CallNode: ExprNode {
  public let arguments: [ExprNode]
  public override var description: String {
    return "CallNode(name: \"\(name)\", arguments: \(arguments))"
  }
  public init(name: String, arguments: [ExprNode]) {
    self.arguments = arguments
    super.init(name: "\(name)")
  }
}

public class PrototypeNode: ExprNode {
  public let argumentNames: [String]
  public override var description: String {
    return "PrototypeNode(name: \"\(name)\", argumentNames: \(argumentNames))"
  }
  public init(name: String, argumentNames: [String]) {
    self.argumentNames = argumentNames
    super.init(name: "\(name)")
  }
}

public class FunctionNode: ExprNode {
  public let prototype: PrototypeNode
  public let body: ExprNode
  public override var description: String {
    return "FunctionNode(prototype: \(prototype), body: \(body))"
  }
  public init(prototype: PrototypeNode, body: ExprNode) {
    self.prototype = prototype
    self.body = body
    super.init(name: "\(prototype.name)")
  }
}
