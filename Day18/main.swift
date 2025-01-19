import Foundation

let mapWidth = 71
let mapHeight = 71
let partOneLimit = 1024

let bytes = input(forDay: 18).split(separator: "\n").map { $0.split(separator: ",").map { Int($0)! } }

let start = Vertex(x: 0, y: 0)
let goal = Vertex(x: mapWidth - 1, y: mapHeight - 1)

struct Vertex: Hashable {
    let x: Int
    let y: Int
}

struct Graph {
    private(set) var vertices = Set<Vertex>()
    private var edges = [Vertex: [Vertex]]()
    
    mutating func addEdge(from: Vertex, to: Vertex) {
        vertices.insert(from)
        vertices.insert(to)
        
        if edges[from] == nil {
            edges[from] = [Vertex]()
        }
        
        edges[from]!.append(to)
    }
    
    // This is really slow and takes > 50% of the runtime
    mutating func remove(vertex: Vertex) {
        vertices.remove(vertex)
        edges.removeValue(forKey: vertex)
        
        for (from, to) in edges {
            edges[from] = to.filter { $0 != vertex }
        }
    }
    
    func paths(from: Vertex) -> [Vertex] {
        return edges[from]!
    }
}

func newGraph() -> Graph {
    var graph = Graph()
    
    for y in 0..<mapHeight {
        for x in 0..<mapWidth {
            let node = Vertex(x: x, y: y)
            
            if x > 0 {
                graph.addEdge(from: node, to: Vertex(x: x - 1, y: y))
            }
            
            if x < mapWidth - 1 {
                graph.addEdge(from: node, to: Vertex(x: x + 1, y: y))
            }
            
            if y > 0 {
                graph.addEdge(from: node, to: Vertex(x: x, y: y - 1))
            }
            
            if y < mapHeight - 1 {
                graph.addEdge(from: node, to: Vertex(x: x, y: y + 1))
            }
        }
    }
    
    return graph
}

func dijkstra(in graph: Graph, startingFrom source: Vertex, seeking target: Vertex) -> Int? {
    var distances = [Vertex: Int]()
    var queue = graph.vertices
    
    for v in queue {
        distances[v] = Int.max
    }
    
    distances[source] = 0
    
    while !queue.isEmpty {
        let v = queue.min { distances[$0]! < distances[$1]! }!
        if v == target {
            break
        }
        
        // We cannot proceed further due to blocks
        if distances[v]! == Int.max {
            break
        }
        
        queue.remove(v)
        
        for next in graph.paths(from: v) {
            let distanceNext = distances[v]! + 1
            
            if distanceNext < distances[next]! {
                distances[next] = distanceNext
            }
        }
    }
    
    return distances[target]! == Int.max ? nil : distances[target]
}

var graph = newGraph()
    
for coord in bytes[0..<partOneLimit] {
    graph.remove(vertex: Vertex(x: coord[0], y: coord[1]))
}

func partOne() -> Int {
    return dijkstra(in: graph, startingFrom: start, seeking: goal)!
}

func partTwo() -> [Int] {
    return binarySearchUpperBound(graph: graph, lowerBound: partOneLimit, upperBound: bytes.count - 1)
}

// Do a binary search for the first index that blocks the exit. Starting from 1024..<bytes.count (we know from part one
// that the first 1024 bytes don't block), check the midpoint. If it's blocked, narrow the search to the lower half;
// otherwise the upper half. Eventually we will converge on the first index that blocks the path (assuming it does
// block of course; if it didn't we'd just end up with the last index of bytes)
// This is not particularly fast due to my comment above about removing vertices from the graph being very slow, but
// it's fast enough for this.
func binarySearchUpperBound(graph: Graph, lowerBound: Int, upperBound: Int) -> [Int] {
    if lowerBound == upperBound {
        return bytes[lowerBound]
    }

    var graphCopy = graph
    
    let testIndex = (lowerBound + upperBound) / 2
    
    for coord in bytes[lowerBound...testIndex] {
        graphCopy.remove(vertex: Vertex(x: coord[0], y: coord[1]))
    }
    
    if dijkstra(in: graphCopy, startingFrom: start, seeking: goal) != nil {
        return binarySearchUpperBound(graph: graphCopy, lowerBound: testIndex + 1, upperBound: upperBound)
    } else {
        // We need to redo this check based on the graph before we applied too many bytes to it
        return binarySearchUpperBound(graph: graph, lowerBound: lowerBound, upperBound: testIndex)
    }
}

print(partOne())
print(partTwo())
