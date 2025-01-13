import Foundation

struct Coordinate: Equatable, Hashable {
    let x: Int
    let y: Int
}

enum Direction: CaseIterable {
    case north, south, east, west
    
    var vector: Coordinate {
        switch self {
        case .north:    Coordinate(x: 0, y: -1)
        case .south:    Coordinate(x: 0, y: 1)
        case .west:     Coordinate(x: -1, y: 0)
        case .east:     Coordinate(x: 1, y: 0)
        }
    }
}

struct Vertex: Hashable {
    let x: Int
    let y: Int
    let facing: Direction
    
    var coordinate: Coordinate {
        Coordinate(x: self.x, y: self.y)
    }
}

struct Edge: Hashable {
    let to: Vertex
    let cost: Int
}

struct Graph {
    private(set) var edges = [Vertex: [Edge]]()
    
    mutating func addEdge(from v1: Vertex, to v2: Vertex) {
        if !edges.keys.contains(v1) {
            edges[v1] = [Edge]()
        }

        edges[v1]!.append(Edge(to: v2, cost: v1.facing == v2.facing ? 1 : 1001))
    }
    
    func edges(from vertex: Vertex) -> [Edge] {
        edges[vertex, default: []]
    }
}

let map = input(forDay: 16)
    .split(separator: "\n")
    .map {
        $0.split(separator: "").map { String($0) }
    }

// Adds the neighbours of the provided vertext to the graph, and returns what it added
func populateNeighbours(in graph: inout Graph, from vertex: Vertex) -> Set<Vertex> {
    var added = Set<Vertex>()

    for direction in Direction.allCases {
        let nextVertex = Vertex(x: vertex.x + direction.vector.x, y: vertex.y + direction.vector.y, facing: direction)
        if map[nextVertex.y][nextVertex.x] == "#" {
            continue
        }
        
        graph.addEdge(from: vertex, to: nextVertex)
        added.insert(nextVertex)
    }
    
    return added
}

func dijkstra(startingFrom source: Vertex, seeking target: Coordinate) -> (
    distances: [Vertex: Int],
    paths: [Vertex: [Vertex?]]
) {
    var graph = Graph()
    
    var distances = [Vertex: Int]()
    var previous = [Vertex: [Vertex?]]()
    
    var visited = Set<Vertex>()
    var queue = Set<Vertex>([source])
    
    distances[source] = 0
    previous[source] = [nil]
    
    while !queue.isEmpty {
        let v = queue.min { distances[$0]! < distances[$1]! }!
        if v.coordinate == target {
            break
        }
        
        visited.insert(v)
        queue.remove(v)
        
        // Lazily populate the neighbours for the current vertex and add them to the queue
        for newVertex in populateNeighbours(in: &graph, from: v) {
            // Skip anything we've already visited to avoid loops, and anything already queued but not yet processed as
            // we might clobber a current lowest distance
            if visited.contains(newVertex) || queue.contains(newVertex) {
                continue
            }
            
            queue.insert(newVertex)
            
            distances[newVertex] = Int.max
            previous[newVertex] = nil
        }
        
        // Slightly modified Dijkstra to support returning all paths
        for edge in graph.edges(from: v) {
            let distanceNext = distances[v]! + edge.cost
            
            if distanceNext < distances[edge.to]! {
                // If we find a new shortest, still disregard the previous as per normal Dijkstra...
                distances[edge.to] = distanceNext
                previous[edge.to] = [v]
            } else if distanceNext == distances[edge.to] {
                // ...but if we find a new joint shortest, add it to the list
                previous[edge.to]!.append(v)
            }
        }
    }
    
    return (distances, previous)
}

let (start, end) = {
    var start: Coordinate? = nil
    var end: Coordinate? = nil
    
    for y in 0..<map.count {
        for x in 0..<map[0].count {
            switch map[y][x] {
            case "S": start = Coordinate(x: x, y: y)
            case "E": end = Coordinate(x: x, y: y)
            default: continue
            }
        }
    }
    
    return (start!, end!)
}()

let (distances, paths) = dijkstra(startingFrom: Vertex(x: start.x, y: start.y, facing: .east), seeking: end)

// Given each path into the end position is a different vertex, we don't actually know what it is for any given input
let endVertex = distances.reduce(Vertex(x: -1, y: -1, facing: .north)) { carry, kv in
    kv.key.coordinate == end && kv.value < distances[carry, default: Int.max] ? kv.key : carry
}

func partOne() -> Int {
    return distances[endVertex]!
}

// Return the set of unique coordinates across all paths back to the start
func enumerateCoordinates(from vertex: Vertex) -> Set<Coordinate> {
    var coords = Set<Coordinate>()
    coords.insert(vertex.coordinate)
    
    for prevVertex in paths[vertex]! {
        // When we hit nil we've got back to the start
        guard let prevVertex = prevVertex else {
            break
        }
        
        coords = coords.union(enumerateCoordinates(from: prevVertex))
    }
    
    return coords
}

func partTwo() -> Int {
    return enumerateCoordinates(from: endVertex).count
}

print(partOne())
print(partTwo())
