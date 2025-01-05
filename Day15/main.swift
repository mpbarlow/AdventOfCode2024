import Foundation

typealias Position = (x: Int, y: Int)

struct ScanRange: Hashable {
    let from: Int
    let to: Int
}

// Not necessary but makes checking next positions much nicer
func +(lhs: Position, rhs: Position) -> Position {
    return (lhs.x + rhs.x, lhs.y + rhs.y)
}

enum CellContentOne {
    case box, wall, nothing
    
    static func from(str: String) -> Self {
        switch str {
        case "#":   .wall
        case "O":   .box
        default:    .nothing
        }
    }
}

enum CellContentTwo {
    case leftBox, rightBox, wall, nothing
}

enum Direction {
    case up, down, left, right
    
    static func from(str: String) -> Self {
        switch str {
        case "^":   .up
        case "v":   .down
        case "<":   .left
        case ">":   .right
        default:    exit(1)
        }
    }
    
    var vector: Position {
        switch self {
        case .up:       (0, -1)
        case .down:     (0, 1)
        case .left:     (-1, 0)
        case .right:    (1, 0)
        }
    }
}

let mapAndMovements = input(forDay: 15).split(separator: /^\n/.anchorsMatchLineEndings())

let movements = mapAndMovements[1]
    .split(separator: "\n")
    .flatMap {
        $0.split(separator: "").map {
            Direction.from(str: String($0))
        }
    }

var robotPos: Position = (0, 0)

var mapOne = mapAndMovements[0]
    .split(separator: "\n")
    .enumerated()
    .map { y, line in
        line.split(separator: "").enumerated().map { x, cell in
            let cell = String(cell)
            if cell == "@" {
                robotPos = (x, y)
            }
            
            return CellContentOne.from(str: cell)
        }
    }

func pushBoxOne(_ direction: Direction) -> Position {
    var position = robotPos + direction.vector
    var toMove = [Position]()

    // The robot can move any number of boxes as long as there's an empty space to move them into
    while mapOne[position.y][position.x] == .box {
        toMove.append(position)
        position = position + direction.vector
    }
    
    // If there's a wall behind them, we can't do anything
    if mapOne[position.y][position.x] == .wall {
        return robotPos
    }
    
    // Otherwise, shift everything along one. Needs to be processed in reverse else you'll overwrite a box you
    // just moved with nothing
    for position in toMove.reversed() {
        let newPos = position + direction.vector
        mapOne[newPos.y][newPos.x] = .box
        mapOne[position.y][position.x] = .nothing
    }
    
    return robotPos + direction.vector
}

func partOne() -> Int {
    for m in movements {
        let nextPos = robotPos + m.vector

        switch mapOne[nextPos.y][nextPos.x] {
        case .nothing:  robotPos = nextPos
        case .box:      robotPos = pushBoxOne(m)
        case .wall:     break
        }
    }
    
    var coords = [Int]()
    
    for y in mapOne.indices {
        for (x, cell) in mapOne[y].enumerated() {
            if cell == .box {
                coords.append((100 * y) + x)
            }
        }
    }
    
    return coords.reduce(0, +)
}

print(partOne())

var mapTwo = mapAndMovements[0]
    .split(separator: "\n")
    .enumerated()
    .map { y, line in
        line.split(separator: "").enumerated().flatMap { x, cell in
            if cell == "@" {
                robotPos = (x * 2, y)
            }
            
            return switch cell {
            case "#": [CellContentTwo.wall, CellContentTwo.wall]
            case "O": [CellContentTwo.leftBox, CellContentTwo.rightBox]
            default: [CellContentTwo.nothing, CellContentTwo.nothing]
            }
        }
    }

// Works similarly to pushBoxOne but with extra logic for pushing boxes in the y-axis. This is a bit of a messy
// solution; I'm sure there's a nice way to generalise it to any width grid, but I already spent a ton of time hunting
// an obvious-in-hindsight bug that only occurs once in my input and left exactly one box in the wrong place.
func pushBoxTwo(_ direction: Direction) -> Position {
    var position = robotPos + direction.vector
    var toMove = [Position]()
    
    switch direction {
    case .left, .right:
        // Pretty much exactly the same as pushBoxOne
        while [CellContentTwo.leftBox, CellContentTwo.rightBox].contains(mapTwo[position.y][position.x]) {
            toMove.append(position)
            position = position + direction.vector
        }
        
        if mapTwo[position.y][position.x] == .wall {
            return robotPos
        }
        
        for position in toMove.reversed() {
            let newPos = position + direction.vector
            mapTwo[newPos.y][newPos.x] = mapTwo[position.y][position.x]
            mapTwo[position.y][position.x] = .nothing
        }
        
        return robotPos + direction.vector

    case .up, .down:
        // A box on one line can "catch" a overhanging box on the next and add it to the set of boxes being pushed,
        // increasing the squares on the line we need to consider, but those squares might be non-contiguous.
        // So we'll track that with a set of ranges.
        var ranges: Set<ScanRange> = mapTwo[position.y][position.x] == .leftBox
        ? Set([ScanRange(from: position.x, to: position.x + 1)])
        : Set([ScanRange(from: position.x - 1, to: position.x)])
        
        while true {
            var foundBox = false
            var nextRanges = Set<ScanRange>()
            
            for range in ranges {
                // Scan the next line from our current crop of boxes
                for x in range.from...range.to {
                    switch mapTwo[position.y][x] {
                    case .wall:
                        // If there is a wall above any box being moved, we can't push
                        return robotPos

                    case .leftBox:
                        foundBox = true
                        nextRanges.insert(ScanRange(from: x, to: x + 1))
                        
                    case .rightBox:
                        foundBox = true
                        nextRanges.insert(ScanRange(from: x - 1, to: x))
                        
                    case .nothing:
                        continue
                    }
                }
            }
            
            // If there are no boxes on the next line, we need to stop looking and perform the actual move
            if !foundBox {
                break
            }
            
            for range in nextRanges {
                for x in range.from...range.to {
                    toMove.append(Position(x: x, y: position.y))
                }
            }
            
            position = position + direction.vector
            ranges = nextRanges
        }
        
        for position in toMove.reversed() {
            let newPos = position + direction.vector
            mapTwo[newPos.y][newPos.x] = mapTwo[position.y][position.x]
            mapTwo[position.y][position.x] = .nothing
        }
        
        return robotPos + direction.vector
    }
}

func partTwo() -> Int {
    for m in movements {
        let nextPos = robotPos + m.vector
        
        switch mapTwo[nextPos.y][nextPos.x] {
        case .nothing:              robotPos = nextPos
        case .leftBox, .rightBox:   robotPos = pushBoxTwo(m)
        case .wall:                 break
        }
    }
    
    var coords = [Int]()
    
    for y in mapTwo.indices {
        for (x, cell) in mapTwo[y].enumerated() {
            if cell == .leftBox {
                coords.append((100 * y) + x)
            }
        }
    }
    
    return coords.reduce(0, +)

}

print(partTwo())
