import Foundation

let file = FileManager.default.currentDirectoryPath + "/Day2/input.txt"
let contents = try? String(contentsOfFile: file, encoding: .utf8)

guard let contents = contents else {
    exit(1)
}

func partOne() -> Int {
    return contents.components(separatedBy: "\n").reduce(0) { carry, line in
        // Bitten by my setting to always end files with a newline...
        if line == "" {
            return carry
        }
        
        if check(subLine: line.components(separatedBy: " ").map { Int($0)! }) {
            return carry + 1
        }
        
        return carry
    }
}

func partTwo() -> Int {
    return contents.components(separatedBy: "\n").reduce(0) { carry, line in
        if line == "" {
            return carry
        }
        
        let levels = line.components(separatedBy: " ").map { Int($0)! }
        
        // We still need to check the whole line; removing an element might invalidate an otherwise valid result
        if check(subLine: levels) {
            return carry + 1
        }
        
        // Check every permutation of the result with one element removed.
        for i in 0..<levels.count {
            var levels = levels
            levels.remove(at: i)
            
            if check(subLine: levels) {
                return carry + 1
            }
        }
        
        return carry
    }
}

func check(subLine: [Int]) -> Bool {
    let direction = (subLine[1] - subLine[0]).signum()
    if direction == 0 {
        return false
    }
    
    for (a, b) in zip(subLine, subLine.dropFirst()) {
        let diff = b - a
                
        // Not consistently ascending or descending, or too big step
        if diff.signum() != direction.signum() || !(1...3).contains(abs(diff)) {
            return false
        }
    }
    
    return true
}

print(partOne())
print(partTwo())
