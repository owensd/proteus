//
//  lexer_tests.swift
//  lexer_tests
//
//  Created by David Owens on 9/3/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

import XCTest
import Foundation

func IsLetter(c: Character?) -> Bool {
    guard let c = c else { return false }
    
    let s = String(c)
    return s.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet()) != nil
}

func IsWhitespace(c: Character?) -> Bool {
    guard let c = c else { return false }
    
    let s = String(c)
    return s.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet()) != nil
}

func IsAlphaNumeric(c: Character?) -> Bool {
    guard let c = c else { return false }

    let s = String(c)
    return s.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet()) != nil
}

func IsIdentifierCharacter(c: Character?) -> Bool {
    guard let c = c else { return false }

    // TODO: Support unicode
    
    return IsAlphaNumeric(c) || c == "_"
}

enum Keyword : String {
    case Import = "import"
}

enum Token : Equatable {
    case EOF
    
    case Keyword(lexer_tests.Keyword, line: Int, column: Int)
    case Identifier(String, line: Int, column: Int)
    case SignificantWhitespace(count: Int, line: Int, column: Int)
    case OpenParen(line: Int, column: Int)
    case CloseParen(line: Int, column: Int)
    case StringLiteral(String, line: Int, column: Int)
}

func ==(lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.EOF, .EOF):
        return true
        
    case let (.Keyword(lkeyword, lline, lcolumn), .Keyword(rkeyword, rline, rcolumn)):
        return lkeyword == rkeyword && lline == rline && lcolumn == rcolumn
        
    case let (.Identifier(lidentifier, lline, lcolumn), .Identifier(ridentifier, rline, rcolumn)):
        return lidentifier == ridentifier && lline == rline && lcolumn == rcolumn
        
    case let (.SignificantWhitespace(lcount, lline, lcolumn), .SignificantWhitespace(rcount, rline, rcolumn)):
        return lcount == rcount && lline == rline && lcolumn == rcolumn
        
    case let (.OpenParen(lline, lcolumn), .OpenParen(rline, rcolumn)):
        return lline == rline && lcolumn == rcolumn

    case let (.CloseParen(lline, lcolumn), .CloseParen(rline, rcolumn)):
        return lline == rline && lcolumn == rcolumn

    case let (.StringLiteral(lstring, lline, lcolumn), .StringLiteral(rstring, rline, rcolumn)):
        return lstring == rstring && lline == rline && lcolumn == rcolumn

    default:
        return false
    }
}

struct PeekableGenerator<Elements : CollectionType> : GeneratorType, SequenceType {
    let elements: Elements
    var generator: Elements.Generator
    var current: Elements.Generator.Element?
    
    init(_ elements: Elements) {
        self.elements = elements
        self.generator = elements.generate()
        self.current = nil
    }
    
    mutating func peek() -> Elements.Generator.Element? {
        return current
    }
    
    mutating func next() -> Elements.Generator.Element? {
        self.current = generator.next()
        return self.current
    }
}

struct Lexer {
    let content: String
    var generator: PeekableGenerator<String.CharacterView>
    
    var line: Int = 1
    var column: Int = 1
    
    init(content: String) {
        self.content = content
        self.generator = PeekableGenerator(content.characters)
        generator.next()
    }
    
    mutating func next() -> Token? {
        func increment() -> Character? {
            column++
            return generator.next()
        }
        
        if generator.peek() == nil { return Token.EOF }
        
        if (IsWhitespace(generator.peek())) {
            let ignore = column != 1
            
            var count = 0
            while (IsWhitespace(increment())) {
                count++
            }
            
            if !ignore {
                return Token.SignificantWhitespace(count: count, line: line, column: 1)
            }
        }
        
        if generator.peek() == "\n" {
            line++
            column = 0
            
            increment()
            return next()
        }
        else if (IsLetter(generator.peek())) {
            let start = column
            
            // gah... this just seems so hacky
            
            var string = String(generator.peek()!)
            while (IsIdentifierCharacter(increment())) {
                string += String(generator.peek()!)
            }
            
            guard let keyword = Keyword.init(rawValue: string) else {
                return Token.Identifier(string, line: line, column: start)
            }
            
            return Token.Keyword(keyword, line: line, column: start)
        }
        else if (generator.peek() == "(") {
            increment()
            return Token.OpenParen(line: line, column: column - 1)
        }
        else if (generator.peek() == ")") {
            increment()
            return Token.CloseParen(line: line, column: column - 1)
        }
        else if (generator.peek() == "\"") {
            let start = column
            
            // gah... this just seems so hacky

            // TODO: This doesn't support nested " characters
            
            increment()
            var string = String(generator.peek()!)
            while (increment() != "\"") {
                string += String(generator.peek()!)
            }
            
            increment()
            return Token.StringLiteral(string, line: line, column: start)
        }
        
        return nil
    }
}

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
