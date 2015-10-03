import Foundation

let path = Process.arguments[1]

let parser = Parser(filename: path)
let ast = try parser.parse()

for statement in ast {
    print("\(statement)")
}

if let code = try? convertASTToC(ast) {
    print("\nC Code\n----")
    print("\(code)")
    try (code as NSString).writeToFile("basic.c", atomically: true, encoding: NSUTF8StringEncoding)
}
else {
    print("error converting AST to C")
}

