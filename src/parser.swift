import Foundation

class Scanner {
    
    var content: String
    var index: String.Index
    var current: Character? = nil

    var line: Int = 0
    var column: Int = 0

    init(content: String) {
        self.content = content
        self.index = content.startIndex
    }

    func next() -> Character? {
        if index == content.endIndex { return nil }

        current = content[index]
        index = index.successor()

        return current
    }

    func peek() -> Character? {
        return current
    }
}

enum Token {
    case Identifier(String)
    case Keyword(String)
    case OpenParen
    case CloseParen
    case StringLiteral(String)
}

class Lexer {

    var scanner: Scanner
    var current: Token? = nil
    
    init(scanner: Scanner) {
        self.scanner = scanner
    }

    func next() -> Token? {
        return nil
    }

    func peek() -> Token? {
        return current
    }
}
