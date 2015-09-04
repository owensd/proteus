//
//  lexer.swift
//  Proteus
//
//  Created by David Owens on 9/4/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

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

enum Keywords : String {
    case Import = "import"
}

enum Token : Equatable {
    case EOF
    
    case Keyword(Keywords, line: Int, column: Int)
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


class Lexer {
    let scanner: Scanner
    
    init(content: String) {
        self.scanner = Scanner(content: content)
    }
    
    func next() -> Token? {
        let (curr, line, column) = scanner.next()
        guard let c = curr else { return .EOF }
        
        if IsWhitespace(c) {
            var count = 0
            while IsWhitespace(scanner.next().curr) {
                count++
            }
            
            scanner.stall()
            
            if column == 1 {
                return .SignificantWhitespace(count: count, line: line, column: column)
            }
            
            return next()
        }
        
        if c == "\n" {
            return next()
        }
        else if IsLetter(c) {
            var string = String(c)
            while IsIdentifierCharacter(scanner.next().curr) {
                string += String(scanner.peek().curr!)
            }
            
            scanner.stall()
            
            guard let keyword = Keywords.init(rawValue: string) else {
                return .Identifier(string, line: line, column: column)
            }
            
            return Token.Keyword(keyword, line: line, column: column)
        }
        else if (c == "(") {
            return Token.OpenParen(line: line, column: column)
        }
        else if (c == ")") {
            return Token.CloseParen(line: line, column: column)
        }
        else if (c == "\"") {
            // TODO: This doesn't support nested " characters
            
            var string = ""
            while scanner.next().curr != "\"" {
                string += String(scanner.peek().curr!)
            }
            
            return Token.StringLiteral(string, line: line, column: column)
        }
        
        return nil
    }
}

