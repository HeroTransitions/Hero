//
//  HeroTests.swift
//  HeroTests
//
//  Created by Luke Zhao on 2/28/17.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import XCTest
import Hero


@discardableResult func parse(_ source: String) throws -> [ExprNode] {
  let lexer = Lexer(input: source)
  let tokens = lexer.tokenize()
  let parser = Parser(tokens: tokens)
  return try parser.parse()
}

class HeroTests: XCTestCase {

  func testNoArg() {
    XCTAssertEqual(try! parse("fade()"), [CallNode(name: "fade", arguments: [])])
    XCTAssertEqual(try! parse("fade"), [VariableNode(name: "fade")])
  }

  func testArg() {
    XCTAssertEqual(try! parse("fade(123, fade)"), [CallNode(name: "fade", arguments: [NumberNode(value: 123), VariableNode(name: "fade")])])
  }

  func testMultiple() {
    XCTAssertEqual(try! parse("fade() fade catch catch(123) catch"),
                   [CallNode(name: "fade", arguments: []),
                    VariableNode(name: "fade"),
                    VariableNode(name: "catch"),
                    CallNode(name: "catch", arguments: [NumberNode(value: 123.0)]),
                    VariableNode(name: "catch")])
  }

  func testNested() {
    XCTAssertEqual(try! parse("fade(fade(catch(123, fade)))"),
       [CallNode(name: "fade", arguments: [
          CallNode(name: "fade", arguments: [
            CallNode(name: "catch", arguments: [
              NumberNode(value: 123.0),
              VariableNode(name: "fade")])
            ])
        ])
      ])
  }

  func testError() throws {
    print(try parse("scale(0.5) translate(200, 0) fade useGlobalCoordinateSpace"))
    XCTAssertThrowsError(try parse("()"), "") { (error) in
      if case ParseError.expectExpression = error {} else {
        XCTFail()
      }
    }
  }

}
