//
//  lexer_tests.swift
//  lexer_tests
//
//  Created by David Owens on 9/3/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import XCTest
import Foundation

class BaselineTests: XCTestCase {
    
    func testEmptyContent() {
        var lexer = Lexer(content: "")

        let token = lexer.next()
        XCTAssertEqual(token, Token.EOF)
    }

    func testHelloWorld() {
        var lexer = Lexer(content: "import stdio\n\nprintln(\"Hello World!\")")
        
        var token: Token?
        
        token = lexer.next()
        XCTAssertEqual(token, Token.Keyword(.Import, line: 1, column: 1))

        token = lexer.next()
        XCTAssertEqual(token, Token.Identifier("stdio", line: 1, column: 8))

        token = lexer.next()
        XCTAssertEqual(token, Token.Identifier("println", line: 3, column: 1))

        token = lexer.next()
        XCTAssertEqual(token, Token.OpenParen(line: 3, column: 8))

        token = lexer.next()
        XCTAssertEqual(token, Token.StringLiteral("Hello World!", line: 3, column: 9))

        token = lexer.next()
        XCTAssertEqual(token, Token.CloseParen(line: 3, column: 23))

        token = lexer.next()
        XCTAssertEqual(token, Token.EOF)
}

}
