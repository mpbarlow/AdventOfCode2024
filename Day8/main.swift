import Foundation

// Convert to 2D array
let map = input(forDay: 8).split(separator: "\n").map { $0.split(separator: "").map { String($0)} }

struct Antinode: Hashable {
    let x: Int
    let y: Int
}

typealias Coordinate = (x: Int, y: Int)

let maxX = map[0].count - 1
let maxY = map.count - 1

// Group up the locations of all frequencies
let frequencies = map.enumerated().reduce(into: [String: [Coordinate]]()) { locations, indexLine in
    let (y, line) = indexLine
    for (x, char) in line.enumerated() {
        if char == "." {
            continue
        }
        
        if !locations.keys.contains(char) {
            locations[char] = [Coordinate]()
        }
        
        locations[char]?.append((x: x, y: y))
    }
}

func partOne() -> Int {
    var antinodes = Set<Antinode>()
    
    for (_, locations) in frequencies {
        for location in locations {
            for otherLocation in locations {
                if location == otherLocation {
                    continue
                }
                
                // Get the X and Y distance between the two nodes and subtract it to get the antinode that's the
                // same distance in the opposite direction.
                let antinodeX = location.x - (otherLocation.x - location.x)
                let antinodeY = location.y - (otherLocation.y - location.y)
                
                if antinodeX < 0 || antinodeX > maxX || antinodeY < 0 || antinodeY > maxY {
                    continue
                }
                
                antinodes.insert(Antinode(x: antinodeX, y: antinodeY))
            }
        }
    }
    
    return antinodes.count
}

func partTwo() -> Int {
    var antinodes = Set<Antinode>()
    
    for (_, locations) in frequencies {
        if locations.count == 1 {
            continue
        }
        
        for location in locations {
            for otherLocation in locations {
                if location == otherLocation {
                    continue
                }
                
                let diffX = otherLocation.x - location.x
                let diffY = otherLocation.y - location.y
                
                for an in computePartTwoAntinodes(location: location, diffX: diffX, diffY: diffY) {
                    antinodes.insert(an)
                }
                
                for an in computePartTwoAntinodes(location: location, diffX: diffX * -1, diffY: diffY * -1) {
                    antinodes.insert(an)
                }
            }
        }
    }
    
    return antinodes.count
}

// Do the exact same thing as part one but keep calculating them at regular intervals of the same distance until we
// go off the end of the map.
func computePartTwoAntinodes(location: Coordinate, diffX: Int, diffY: Int) -> [Antinode] {
    var antinodes = [Antinode]()
    
    var nextX = location.x
    var nextY = location.y
    
    while true {
        nextX += diffX
        nextY += diffY
        
        if nextX < 0 || nextX > maxX || nextY < 0 || nextY > maxY {
            break
        }
        
        antinodes.append(Antinode(x: nextX, y: nextY))
    }
    
    return antinodes
}


print(partOne())
print(partTwo())
