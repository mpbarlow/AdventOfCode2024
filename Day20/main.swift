import Foundation

// This ended up being quite easy, but I wasted somewhere around four hours trying to optimise an implementation of
// Dijkstra's algorithm to work with this (unsuccessfully, obviously). It worked for part one but took several minutes
// to get there. Given there is only a single path, using a pathfinding algorithm clearly wasn't right, but because
// effectively removing a wall adds a loop, I thought there might be something to it.

let map = input(forDay: 20)
    .split(separator: "\n")
    .map { $0.split(separator: "").map { String($0) } }

let mapHeight = map.count
let mapWidth = map[0].count

struct Node: Hashable {
    let x: Int
    let y: Int
}

struct Track {
    private(set) var path = [Node]()
    private var distances = [Node: Int]()
    
    mutating func add(node: Node, withDistance dist: Int) {
        path.append(node)
        distances[node] = dist
    }
    
    func distance(of node: Node) -> Int? {
        return distances[node]
    }
}

let directions: [(x: Int, y: Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
let acrossWallDirections = directions.map { (x: $0.x * 2, y: $0.y * 2) }

func buildTrack() -> Track {
    var path = Track()
    
    func followPath(from current: Node, distance: Int = 0, previous: Node? = nil) {
        path.add(node: current, withDistance: distance)
        if map[current.y][current.x] == "E" {
            return
        }
        
        for dir in directions {
            let next = Node(x: current.x + dir.x, y: current.y + dir.y)
            if map[next.y][next.x] == "#" || next == previous {
                continue
            }
            
            return followPath(from: next, distance: distance + 1, previous: current)
        }
    }
    
outer:
    for y in 0..<mapHeight {
        for x in 0..<mapWidth {
            if map[y][x] == "S" {
                followPath(from: Node(x: x, y: y))
                break outer
            }
        }
    }
    
    return path
}

let track = buildTrack()

func partOne() -> Int {
    var cheatCount = 0
    
    // For each node on the path, see if there is a node in the place you'd get to via cheating. If there is, see if
    // taking that cheat saves >= 100 steps (we need to -1 cause the cheat itself costs one step)
    for (distance, node) in track.path.enumerated() {
        for dir in acrossWallDirections {
            if
                let prevDistance = track.distance(of: Node(x: node.x + dir.x, y: node.y + dir.y)),
                prevDistance - distance - 1 >= 100
            {
                cheatCount += 1
            }
        }
    }
    
    return cheatCount
}

func partTwo() -> Int {
    var cheatCount = 0
    
    // For each node to each node ahead of it that is <= 20 squares away by Manhattan distance (not heard that term
    // before), see if cheating there by any path (we don't care what the path is) saves >= 100 steps.
    for (index, n1) in track.path.enumerated() {
        if index == track.path.indices.last {
            break
        }
        
        for n2 in track.path[index..<track.path.count] {
            let cheatDistance = abs(n2.x - n1.x) + abs(n2.y - n1.y)
            if cheatDistance > 20 {
                continue
            }
            
            if track.distance(of: n2)! - track.distance(of: n1)! - cheatDistance >= 100 {
                cheatCount += 1
            }
        }
    }
    
    return cheatCount
}

print(partOne())
print(partTwo())
