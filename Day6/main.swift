import Foundation

// Break the input into a 2D String array
let grid = input(forDay: 6)
    .split(separator: "\n")
    .map {
        $0.split(separator: "").map { String($0) }
    }

struct Coordinate: Hashable {
    let x: Int
    let y: Int
}

struct Vector: Hashable {
    let coordinate: Coordinate
    let direction: Direction
}

enum Direction {
    case up, left, down, right

    var step: Coordinate {
        switch self {
        case .up: Coordinate(x: 0, y: -1)
        case .left: Coordinate(x: -1, y: 0)
        case .down: Coordinate(x: 0, y: 1)
        case .right: Coordinate(x: 1, y: 0)
        }
    }
    
    var nextDirection: Self {
        switch self {
        case .up: .right
        case .right: .down
        case .down: .left
        case .left: .up
        }
    }
    
    func nextPosition(from current: Coordinate) -> Coordinate {
        Coordinate(x: current.x + self.step.x, y: current.y + self.step.y)
    }
}

// Find the start position
let start = {
    for i in 0..<grid.count {
        for j in 0..<grid[0].count {
            if grid[i][j] == "^" {
                return Coordinate(x: j, y: i)
            }
        }
    }
    
    exit(1)
}()

func partOne() -> Int {
    var currentVector = Vector(coordinate: start, direction: .up)
    var coords = Set<Coordinate>()
    
    while true {
        coords.insert(currentVector.coordinate)
        
        guard let nextVector = step(grid: grid, currentVector: currentVector) else {
            break
        }
        
        currentVector = nextVector
    }
    
    return coords.count
}

func partTwo() -> Int {
    var validObstacles = 0
    
    var prevVectors = Set<Vector>()
    var prevCoords = Set<Coordinate>()
    
    var currentVector = Vector(coordinate: start, direction: .up)
    
    while true {
        prevVectors.insert(currentVector)
        prevCoords.insert(currentVector.coordinate)
        
        // Get the nextVector so we know where to try putting an obstacle. i.e. don't try putting one where we're not
        // gonna be walking anyway
        guard let nextVector = step(grid: grid, currentVector: currentVector) else {
            // We've ran out of places to try putting obstacles
            break
        }
        
        // Plonk an obstacle there and see if it results in a loop, but _only_ if it's a square we haven't already
        // crossed on the walk (thanks reddit)
        var modifiedGrid = grid
        if !prevCoords.contains(nextVector.coordinate) {
            modifiedGrid[nextVector.coordinate.y][nextVector.coordinate.x] = "#"
        }
        
        // Thank u value types
        if walk(modifiedGrid: modifiedGrid, prevVectors: prevVectors, currentVector: currentVector) {
            validObstacles += 1
        }
        
        currentVector = nextVector
    }
    
    return validObstacles
}

// Return the next vector given the current for a particular grid
func step(grid: [[String]], currentVector: Vector) -> Vector? {
    let nextCoord = currentVector.direction.nextPosition(from: currentVector.coordinate)
    
    // Left the grid
    if nextCoord.x < 0 || nextCoord.x >= grid[0].count || nextCoord.y < 0 || nextCoord.y >= grid.count {
        return nil
    }

    // Either rotate or take a step forward depending on if there's an obstacle
    return grid[nextCoord.y][nextCoord.x] == "#"
        ? Vector(coordinate: currentVector.coordinate, direction: currentVector.direction.nextDirection)
        : Vector(coordinate: nextCoord, direction: currentVector.direction)
}

// Walk a modified grid until we either walk off the end (no loop) or encounter a vector we've seen before (loop)
// I feel like there's a way to not repeat this logic three times with slightly different return values but meh
func walk(modifiedGrid grid: [[String]], prevVectors: Set<Vector>, currentVector: Vector) -> Bool {
    var prevVectors = prevVectors
    var currentVector = currentVector
    
    while true {
        prevVectors.insert(currentVector)
        
        // Left the grid; can't be a loop
        guard let nextVector = step(grid: grid, currentVector: currentVector) else {
            return false
        }
        
        // If we've previously been on this spot, in this direction, we're in a loop
        if prevVectors.contains(nextVector) {
            return true
        }
        
        currentVector = nextVector
    }
}

print(partOne())
print(partTwo())
