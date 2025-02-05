import Foundation

let (locks, keys) = input(forDay: 25)
    .split(separator: /^\n/.anchorsMatchLineEndings())
    .map {
        $0.split(separator: "\n").map { String($0) }
    }
    .reduce(into: (locks: [[String]](), keys: [[String]]())) { input, lockOrKey in
        if lockOrKey.first! == "#####" {
            input.locks.append(lockOrKey)
        } else if lockOrKey.last! == "#####" {
            input.keys.append(lockOrKey)
        }
    }

let lockWidth = locks.first!.first!.count
let maxLockHeight = locks.first!.count

func getHeights(of lockOrKey: [String]) -> [Int] {
    let split = lockOrKey.map { $0.split(separator: "") }
    var heights = [Int](repeating: 0, count: lockWidth)
    
    for x in 0..<lockWidth {
        for y in 0..<maxLockHeight {
            if split[y][x] == "#" {
                heights[x] += 1
            }
        }
    }
    
    return heights
}

let lockHeights = locks.map(getHeights(of:))
let keyHeights = keys.map(getHeights(of:))

func partOne() -> Int {
    var possiblePairs = 0
    
    for lock in lockHeights {
    outer:
        for key in keyHeights {
            for x in 0..<lockWidth {
                if lock[x] + key[x] > maxLockHeight {
                    continue outer
                }
            }
            
            possiblePairs += 1
        }
    }
    
    return possiblePairs
}

print(partOne())
