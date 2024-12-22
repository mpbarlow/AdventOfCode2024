import Foundation

let stones = input(forDay: 11)
    .split(separator: " ")
    .map { String($0).trimmingCharacters(in: ["\n"]) }

var cache = [String: [Int: [Int: Int]]]()

func partOne() -> Int {
    return stones.reduce(0) { carry, stone in
        carry + blink(at: stone, from: 1, upTo: 25)
    }
}

func partTwo() -> Int {
    return stones.reduce(0) { carry, stone in
        carry + blink(at: stone, from: 1, upTo: 75)
    }
}

// First attempt at this was the naive for-loop which of course works just fine but goes for god knows how long on
// part two. There was a similar problem last year that just needed memoization adding. Always surprised how much it
// helps this kind of problem.
func blink(at stone: String, from current: Int, upTo target: Int) -> Int {
    if let result = cache[stone]?[target]?[current] {
        return result
    }

    if current > target {
        return 1
    }
    
    let result: Int
    
    switch stone {
    case "0":
        result = blink(at: "1", from: current + 1, upTo: target)
        
    case let s where s.count.isMultiple(of: 2):
        let midpoint = s.index(s.startIndex, offsetBy: s.count / 2)
        
        let firstHalf = String(s[s.startIndex..<midpoint])
        let secondHalf = String(Int(s[midpoint...])!) // Extra Int() cast to strip off any leading zeroes
        
        result = blink(at: firstHalf, from: current + 1, upTo: target)
        + blink(at: secondHalf, from: current + 1, upTo: target)
        
    default:
        result = blink(at: String(Int(stone)! * 2024), from: current + 1, upTo: target)
    }
    
    if !cache.keys.contains(stone) {
        cache[stone] = [Int: [Int: Int]]()
    }
    
    if !cache[stone]!.keys.contains(target) {
        cache[stone]![target] = [Int: Int]()
    }

    cache[stone]![target]![current] = result
    
    return result
}

print(partOne())
print(partTwo())
