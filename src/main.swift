import Foundation

let path = Process.arguments[1]

let content: String = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
let scanner = Scanner(content: content)


while scanner.next() != nil {
    print(scanner.peek()!, terminator: "")
}
