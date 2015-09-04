//
//  scanner.swift
//  Proteus
//
//  Created by David Owens on 9/4/15.
//  Copyright © 2015 owensd.io. All rights reserved.
//

class Scanner {
    var generator: IndexingGenerator<String.CharacterView>
    var line: Int = 1
    var column: Int = 0
    
    var curr: Character?
    
    var shouldStall: Bool
    
    init(content: String) {
        self.generator = content.characters.generate()
        self.curr = nil
        self.shouldStall = false
    }
    
    func stall() {
        shouldStall = true
    }
    
    func peek() -> (curr: Character?, line: Int, column: Int) {
        return (curr, line, column)
    }
    
    func next() -> (curr: Character?, line: Int, column: Int) {
        if shouldStall {
            shouldStall = false
            return peek()
        }
        else {
            if curr == "\n" {
                line++
                column = 1
            }
            else {
                column++
            }
            
            curr = generator.next()
            
            return (curr, line, column)
        }
    }
}