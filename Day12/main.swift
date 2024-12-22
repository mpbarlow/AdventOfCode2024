import Foundation

let map = input(forDay: 12)
    .split(separator: "\n")
    .map { $0.split(separator: "") }

let maxX = map[0].count - 1
let maxY = map.count - 1

struct Coordinate: Hashable {
    let x: Int
    let y: Int
}

enum EdgeTracking {
    case before, after, none
}

struct Plot {
    let label: String
    let positions: Set<Coordinate>
    
    var area: Int {
        positions.count
    }
    
    var perimeter: Int {
        // The perimeter of each position is the number of sides where its neighbour is not part of the plot
        positions.reduce(0) { carry, coord in
            carry + directions
                .filter { dir in !positions.contains(Coordinate(x: coord.x + dir.x, y: coord.y + dir.y)) }
                .count
        }
    }
    
    // Lay a series of "grid lines" between the squares, and along each line track whether we have a square on the left
    // or right (above/below for horizontal lines). An edge can only be a case where there's a square on one side OR the
    // other, so we track when that changes (including if it swaps from one to the other in one move) and increment the
    // edge count accordingly.
    // The smort way to do this would have been to count corners which probably involves a lot fewer set lookups.
    var sides: Int {
        let xs = positions.map { $0.x }
        // +1 because we'll treat the line as being "to the left" of the square, so for the rightmost one we need to be
        // one further
        let rangeX = xs.min()!...(xs.max()! + 1)
        
        let ys = positions.map { $0.y }
        let rangeY = ys.min()!...(ys.max()! + 1)
        
        var edges = 0
        
        var trackingEdge = EdgeTracking.none {
            willSet {
                if newValue != .none && newValue != trackingEdge {
                    edges += 1
                }
            }
        }
        
        for x in rangeX {
            for y in rangeY {
                let before = positions.contains(Coordinate(x: x - 1, y: y))
                let after = positions.contains(Coordinate(x: x, y: y))
                
                if before && !after {
                    trackingEdge = .before
                } else if !before && after {
                    trackingEdge = .after
                } else {
                    trackingEdge = .none
                }
            }
        }
        
        trackingEdge = .none
        
        for y in rangeY {
            for x in rangeX {
                let before = positions.contains(Coordinate(x: x, y: y - 1))
                let after = positions.contains(Coordinate(x: x, y: y))

                if before && !after {
                    trackingEdge = .before
                } else if !before && after {
                    trackingEdge = .after
                } else {
                    trackingEdge = .none
                }
            }
        }
        
        return edges
    }
}

// Right, down, left, up
let directions: [(x: Int, y: Int)] = [(1, 0), (0, 1), (-1, 0), (0, -1)]

func buildPlotList() -> [Plot] {
    var plots = [Plot]()
    var visitedPositions = Set<Coordinate>()

    for (y, line) in map.enumerated() {
        for (x, cell) in line.enumerated() {
            // Don't re-generate anything in a plot we've already seen
            if visitedPositions.contains(Coordinate(x: x, y: y)) {
                continue
            }
            
            // Get all positions in the plot
            let plotPositions = explorePlot(x: x, y: y)
            visitedPositions = visitedPositions.union(plotPositions)
            
            plots.append(Plot(label: String(cell), positions: plotPositions))
        }
    }
    
    return plots
}

// Recursively build up the set of co-ordinates of positions in the same plot as (x, y)
func explorePlot(x: Int, y: Int, visited: Set<Coordinate> = Set<Coordinate>()) -> Set<Coordinate> {
    var visited = visited
    visited.insert(Coordinate(x: x, y: y))

    for dir in directions {
        let nextX = x + dir.x
        let nextY = y + dir.y
        
        // Square is OoB
        if nextX < 0 || nextX > maxX || nextY < 0 || nextY > maxY {
            continue
        }
        
        // We've already visited
        if visited.contains(Coordinate(x: nextX, y: nextY)) {
            continue
        }
        
        // The next position is in a different plot
        if map[nextY][nextX] != map[y][x] {
            continue
        }
        
        visited = visited.union(explorePlot(x: nextX, y: nextY, visited: visited))
    }
    
    return visited
}

func partOne() -> Int {
    return buildPlotList().reduce(0) { carry, plot in
        carry + (plot.area * plot.perimeter)
    }
}

func partTwo() -> Int {
    return buildPlotList().reduce(0) { carry, plot in
        carry + (plot.area * plot.sides)
    }
}

print(partOne())
print(partTwo())
