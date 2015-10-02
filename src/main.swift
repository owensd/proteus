import Foundation

let path = Process.arguments[1]

let parser = Parser(filename: path)
let tokens = try parser.parse()

for token in tokens {
    print("parsed token: \(token)")
}
