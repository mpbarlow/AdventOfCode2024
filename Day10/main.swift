import Foundation

let map = input(forDay: 10)
    .split(separator: "\n")
    .map { $0.split(separator: "").map { Int($0)! } }

let maxX = map[0].count - 1
let maxY = map.count - 1

// Up, down, left, right
let possibleDirections: [(x: Int, y: Int)] = [(0, -1), (0, 1), (-1, 0), (1, 0)]

// Just so I can can be lazy and get the unique endpoints using Set
struct Position: Hashable {
    let x: Int
    let y: Int
}

// Recursively attempt to step to the next point on the trail if it's a valid place to go, returning position of each
// 9 encountered from this point
func step(pos: Position, level: Int) -> [Position] {
    // We've successfully navigated a trail
    if level == 9 {
        return [pos]
    }
    
    var positions = [Position]()
    
    for direction in possibleDirections {
        let nextX = pos.x + direction.x
        let nextY = pos.y + direction.y
        
        // Can't go off the board
        if nextX < 0 || nextX > maxX || nextY < 0 || nextY > maxY {
            continue
        }
        
        // We can move here
        if map[nextY][nextX] == level + 1 {
            positions += step(pos: Position(x: nextX, y: nextY), level: level + 1)
        }
    }
    
    return positions
}

// For part one we only count the number of unique 9s from each path. For part two we count all paths.
// Like many others, I did not read the problem correctly and accidentally did part two first.
func partOne() -> Int {
    var positions = [Position]()
    
    for y in 0...maxY {
        for x in 0...maxX {
            if map[y][x] == 0 {
                positions += Array(Set(step(pos: Position(x: x, y: y), level: 0)))
            }
        }
    }
        
    return positions.count
}

// For part two we want the number of unique paths
func partTwo() -> Int {
    var positions = [Position]()
    
    for y in 0...maxY {
        for x in 0...maxX {
            if map[y][x] == 0 {
                positions += step(pos: Position(x: x, y: y), level: 0)
            }
        }
    }
        
    return positions.count
}

print(partOne())
print(partTwo())
