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

// This is slow as hell, takes about 2 mins to run but...eh
func partTwo() -> Int {
    // Cursed dict. Maps:
    // Initial secret: sequence of changes: the price that yields
    var seen = [Int: [[Int]: Int]]()
    
    for number in numbers {
        seen[number] = [[Int]: Int]()
        
        var secret = number
        var sequence = [Int]()
        
        for _ in 0..<2000 {
            let oldPrice = secret % 10
            secret = nextSecretNumber(from: secret)
            let price = secret % 10
            
            sequence.append(price - oldPrice)
            
            let last4 = Array(sequence.suffix(4))
            if last4.count < 4 || seen[number]![last4] != nil {
                continue
            }
            
            seen[number]![last4] = price
        }
    }
    
    var mostBananas = -1
    
    for sequence in Set(seen.mapValues { $0.keys }.values.reduce([], +)) {
        var bananas = 0
        
        for number in numbers {
            bananas += seen[number]![sequence, default: 0]
        }
        
        if bananas > mostBananas {
            mostBananas = bananas
        }
    }
    
    return mostBananas
}

print(partOne())
print(partTwo())
