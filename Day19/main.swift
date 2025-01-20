import Foundation

let availableAndDesired = input(forDay: 19).split(separator: /^\n/.anchorsMatchLineEndings())

let availablePatterns = availableAndDesired[0]
    .split(separator: ", ")
    .map { String($0).trimmingCharacters(in: ["\n"]) }

let desired = availableAndDesired[1].split(separator: "\n")

var memo = [String.SubSequence: Int]()

// I was a massive, hubris-filled idiot with this. I guessed part two would be something about all combinations, so
// wrote this function to enumerate all possibilities. Saw part two and knew I needed memoization.
// Then spent ages debugging why it was still impossibly slow, before realising that no part of the solution requires
// me to actually list all the combinations.
// Turns out memoization doesn't have much effect when you're trying to allocate trillions of strings.
func countCombinations(composing desired: String.SubSequence) -> Int {
    guard memo[desired] == nil else {
        return memo[desired]!
    }
    
    var matches = 0
    
    for p in availablePatterns {
        // Pattern too long
        if p.count > desired.count {
            continue
        }
        
        if desired.prefix(p.count) == p {
            // Full match; no need to recurse further
            if desired.count == p.count {
                matches += 1
                continue
            }
            
            matches += countCombinations(composing: desired.suffix(desired.count - p.count))
        }
    }
    
    memo[desired] = matches
    
    return matches
}

let combinations = desired.map { countCombinations(composing: $0) }

func partOne() -> Int {
    return combinations.reduce(0) { carry, combination in
        carry + (combination > 0 ? 1 : 0)
    }
}

func partTwo() -> Int {
    return combinations.reduce(0) { carry, combination in
        carry + combination
    }
}

print(partOne())
print(partTwo())
