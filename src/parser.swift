import Foundation

struct ScannerInfo {
    let character: Character?
    let line: Int
    let column: Int
}

class Scanner {
    
    var content: String
    var index: String.Index
    var current: ScannerInfo? = nil

    private var shouldStall = false

    var line: Int = 0
    var column: Int = 0 

    init(content: String) {
        self.content = content
        self.index = content.startIndex
    }

    func stall() {
        shouldStall = true
    }

    func next() -> ScannerInfo? {
        if shouldStall {
            shouldStall = false
            return current
        }
        
        if index == content.endIndex {
            current = nil 
        }
        else {
            current = ScannerInfo(character: content[index], line: line, column: column)
            index = index.successor()

            if current?.character == "\n" {
                line++
                column = 0 
            }
            else {
                column++
            }
        }

        return current 
    }

    func peek() -> ScannerInfo? {
        return current
    }
}

enum Token {
    case Identifier(String, line: Int, column: Int)
    case Keyword(String, line: Int, column: Int)
    case OpenParen(line: Int, column: Int)
    case CloseParen(line: Int, column: Int)
    case StringLiteral(String, line: Int, column: Int)
    case Terminal(line: Int, column: Int)
    case EOF

    var stringValue: String {
        switch self {
        case let .Identifier(value, _, _): return value
        case let .StringLiteral(value, _, _): return value
        case let .Keyword(value, _, _): return value
        default: return ""
        }
    }
}

func isCharacterPartOfSet(c: Character?, set: NSCharacterSet) -> Bool {
    guard let c = c else { return false }
    var isMember = true

    for utf16Component in String(c).utf16 {
        if !set.characterIsMember(utf16Component) { isMember = false; break }
    }

    return isMember
}

func isValidIdentifierSignalCharacter(c: Character?) -> Bool {
    return isCharacterPartOfSet(c, set: NSCharacterSet.letterCharacterSet()) 
}

func isValidIdenitifierCharacter(c: Character?) -> Bool {
    return isCharacterPartOfSet(c, set: NSCharacterSet.letterCharacterSet()) 
}

func isWhitespace(c: Character?) -> Bool {
    return isCharacterPartOfSet(c, set: NSCharacterSet.whitespaceCharacterSet())
}

let keywords = ["import", "func"]

class Lexer {

    var scanner: Scanner
    var current: Token? = nil
    
    init(scanner: Scanner) {
        self.scanner = scanner
    }

    func next() -> Token? {
        func work() -> Token? {
            if scanner.next() == nil { return .EOF }

            scanner.stall()

            while let info = scanner.next() where isWhitespace(info.character) {}
            scanner.stall()

            guard let next = scanner.next() else { return .EOF }

            if next.character == "\n" {
                return .Terminal(line: next.line, column: next.column)
            }
            else if isValidIdentifierSignalCharacter(next.character) {
                var content = String(next.character!)
                while let info = scanner.next() where isValidIdenitifierCharacter(info.character) {
                    content.append(info.character!)
                }
                scanner.stall()

                if keywords.contains(content) {
                    return .Keyword(content, line: next.line, column: next.column)
                }
                else {
                    return .Identifier(content, line: next.line, column: next.column)
                }
            }
            else if next.character == "(" {
                return .OpenParen(line: next.line, column: next.column)
            }
            else if next.character == ")" {
                return .CloseParen(line: next.line, column: next.column)
            }
            else if next.character == "\"" {
                var content = String(next.character!)
                while let info = scanner.next() where info.character != "\"" {
                    content.append(info.character!)
                }
                content.append(scanner.peek()!.character!)

                return .StringLiteral(content, line: next.line, column: next.column)
            }

            return nil
        }

        if case .EOF? = self.current {
            self.current = nil
        }
        else {
            self.current = work()
        }
        
        return self.current
    }

    func tokenize() -> [Token] {
        var tokens = [Token]()

        while let token = self.next() { tokens.append(token) }

        return tokens
    }

    func peek() -> Token? {
        return current
    }
}

enum Error : ErrorType {
    case InvalidSyntax(String)
    case Generic(String)
}

enum Statement {
    case Import(keyword: Token, value: Token)
    case Function(name: Token, params: [Token])
}

class Parser {
    let filename: String

    init(filename: String) {
        self.filename = filename
    }

    func parse() throws -> [Statement] {
        let content: String = try NSString(contentsOfFile: self.filename, encoding: NSUTF8StringEncoding) as String
        let scanner = Scanner(content: content)
        
        let lexer = Lexer(scanner: scanner)

        var parsed = [Statement]()
        while let _ = lexer.next() {
            if let importStatement = try parseImport(lexer) {
                parsed.append(importStatement)
            }
            else if let functionInvocationStatement = try parseFunctionInvocationStatement(lexer) {
                parsed.append(functionInvocationStatement)
            }
        }

        return parsed
    }
}

func parseImport(lexer: Lexer) throws -> Statement? {
    guard let keywordToken = lexer.peek() else { return nil }
    guard case let .Keyword(keyword, _, _) = keywordToken where keyword == "import" else { return nil }
    
    guard let identifierToken = lexer.next() else { throw Error.InvalidSyntax("Expected identifier") }
    guard case .Identifier(_, _, _) = identifierToken else { throw Error.InvalidSyntax("Expected identifier") }
    guard case .Terminal(_, _)? = lexer.next() else { throw Error.InvalidSyntax("Expected terminal") }

    return .Import(keyword: keywordToken, value: identifierToken)
}

func parseFunctionInvocationStatement(lexer: Lexer) throws -> Statement? {
    guard let identifierToken = lexer.peek() else { return nil }
    guard case .Identifier = identifierToken else { return nil }

    guard let openParenToken = lexer.next() else { return nil }
    guard case .OpenParen = openParenToken else { return nil }

    var params = [Token]()

    while let nextToken = lexer.next() {
        switch nextToken {
        case .CloseParen:
            if case .Terminal? = lexer.next() {
                return .Function(name: identifierToken, params: params)
            }
            else {
                throw Error.InvalidSyntax("Invalid function invocation")
            }

        case .StringLiteral:
            params.append(nextToken)
        
        default:
            throw Error.InvalidSyntax("Invalid function invocation")
        }
    }

    throw Error.InvalidSyntax("Invalid function invocation") 
}

func convertASTToC(ast: [Statement]) throws -> String {
    var code = ""

    for statement in ast {
        switch statement {
        case let .Import(_, value): 
            if value.stringValue == "stdlib" {
                code += "#include <stdio.h>\n"
            }
            else {
                throw Error.Generic("This import is not yet handled.")
            }
            
        case let .Function(identifier, params):
            // TODO(owensd): Fix the super hack here!

            code += "int main(int argc, char **argv) {\n"

            if identifier.stringValue == "print" {
                code += "printf("
                code += (params.map { $0.stringValue } as NSArray).componentsJoinedByString(",")
                code += "\n);"
            }

            code += "\nreturn 0;}\n"
        }
    }

    return code 
}
