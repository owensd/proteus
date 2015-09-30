import Foundation

let path = Process.arguments[1]

let content: String = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
let scanner = Scanner(content: content)

let lexer = Lexer(scanner: scanner)
tokenLoop: while let token = lexer.next() {
    switch token {
        case .EOF: print("token: EOF"); break tokenLoop
        default: print("token: \(token)")
   }
    
}


