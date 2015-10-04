import Foundation

let path = Process.arguments[1]

let content: String = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
let scanner = Scanner(content: content)
// scanner.debugPrint()
        
let lexer = Lexer(scanner: scanner)
lexer.debugPrint()

let parser = Parser(lexer: lexer)
let ast = try parser.parse()

print("--- AST ---")
for statement in ast {
    print("\(statement)")
}
print("")

let outputPath = "basic.c"
if let code = try? convertASTToC(ast) {
    print("--- C Code ---")
    print("\(code)")
    try (code as NSString).writeToFile(outputPath, atomically: true, encoding: NSUTF8StringEncoding)
}
else {
    print("error converting AST to C")
}

let task = NSTask()
task.launchPath = "/usr/bin/clang"
task.arguments = [ outputPath, "-o", "temp" ] 
task.launch()
task.waitUntilExit()

