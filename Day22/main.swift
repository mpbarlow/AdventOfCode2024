import Foundation

let numbers = input(forDay: 22).split(separator: "\n").map { Int($0)! }

let prune = 16777216

func nextSecretNumber(from input: Int) -> Int {
    var secret = input
    
    secret = (secret ^ (secret * 64)) % prune
    secret = (secret ^ (secret / 32)) % prune
    
    return (secret ^ (secret * 2048)) % prune
}

func partOne() -> Int {
    var total = 0
    
    for number in numbers {
        var secret = number
        
        for _ in 0..<2000 {
            secret = nextSecretNumber(from: secret)
        }
        
        total += secret
    }
    
    return total
}

func partTwo() -> Int {
    // Map the first occurence of sequences for each monkey onto a running total of how many bananas it yields
    var seen = [[Int]: Int]()
    
    for number in numbers {
        var secret = number
        
        var sequence = [Int]()
        var seenOnCurrent = Set<[Int]>()
        
        for _ in 0..<2000 {
            let oldPrice = secret % 10
            secret = nextSecretNumber(from: secret)
            let price = secret % 10
            
            sequence = sequence.suffix(3) + [price - oldPrice]
            if sequence.count < 4 || seenOnCurrent.contains(sequence) {
                continue
            }
            
            seenOnCurrent.insert(sequence)
            seen[sequence, default: 0] += price
        }
    }
    
    return seen.values.max()!
}

print(partOne())
print(partTwo())
