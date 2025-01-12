import Foundation

typealias Coordinate = (x: Int, y: Int)

let map = input(forDay: 16)
    .split(separator: "\n")
    .map {
        $0.split(separator: "").map { String($0) }
    }

enum Direction: CaseIterable {
    case north, south, east, west
    
    var vector: Coordinate {
        switch self {
        case .north:    (0, -1)
        case .south:    (0, 1)
        case .west:     (-1, 0)
        case .east:     (1, 0)
        }
    }
}

struct Vertex: Hashable, Equatable {
    let x: Int
    let y: Int
}

struct Edge: Hashable {
    let from: Vertex
    let to: Vertex
    let direction: Direction
}

struct Graph {
    private(set) var vertices = Set<Vertex>()
    private(set) var edges = Set<Edge>()
    
    mutating func addEdge(from v1: Vertex, to v2: Vertex, toThe direction: Direction) {
        vertices.insert(v1)
        vertices.insert(v2)
        edges.insert(Edge(from: v1, to: v2, direction: direction))
    }
    
    func edges(from vertex: Vertex) -> [Edge] {
        edges.filter { $0.from == vertex }
    }
}

func buildGraph() -> Graph {
    var graph = Graph()
    
    // Don't both processing the edge walls
    for y in 1..<map.count - 1 {
        for x in 1..<map[y].count - 1 {
            if map[y][x] == "#" {
                // Can't be on a wall
                continue
            }

            let v1 = Vertex(x: x, y: y)

            for direction in Direction.allCases {
                let v2 = Vertex(x: x + direction.vector.x, y: y + direction.vector.y)
                
                if map[v2.y][v2.x] == "#" {
                    continue
                }
                
                graph.addEdge(from: v1, to: v2, toThe: direction)
            }
        }
    }
    
    return graph
}

func dijkstra(_ graph: Graph, startingFrom source: Vertex) -> (distances: [Vertex: Int], paths: [Vertex: Vertex?]) {
    var distances = [Vertex: Int]()
    var previous = [Vertex: Vertex?]()
    // We need to track the direction we're facing on the current shortest path to each vertex to know whether a
    // neighbour visit will require a turn
    var directions = [Vertex: Direction?]()
    
    var queue = graph.vertices
    
    for v in queue {
        distances[v] = Int.max
        previous[v] = nil
        directions[v] = nil
    }
    
    distances[source] = 0
    directions[source] = .east
    
    while !queue.isEmpty {
        let v = queue.min { distances[$0]! < distances[$1]! }!
        queue.remove(v)
        
        for edge in graph.edges(from: v) {
            let distanceNext = distances[v]! + 1 + (directions[v] == edge.direction ? 0 : 1000)

            if distanceNext < distances[edge.to]! {
                distances[edge.to] = distanceNext
                previous[edge.to] = v
                directions[edge.to] = edge.direction
            }
        }
    }
    
    return (distances, previous)
}

let (start, end) = {
    var start: Vertex = Vertex(x: 0, y: 0)
    var end: Vertex = Vertex(x: 0, y: 0)
    
    for y in 0..<map.count {
        for x in 0..<map[0].count {
            switch map[y][x] {
            case "S": start = Vertex(x: x, y: y)
            case "E": end = Vertex(x: x, y: y)
            default: continue
            }
        }
    }
    
    return (start, end)
}()

func partOne() -> Int {
    let (distances, _) = dijkstra(buildGraph(), startingFrom: start)

    return distances[end]!
}

// 75416
print(partOne())
