import Foundation

struct Graph {
    private(set) var nodes = [String: Set<String>]()
    
    mutating func addConnection(_ node1: String, _ node2: String) {
        nodes[node1, default: Set<String>()].insert(node2)
        nodes[node2, default: Set<String>()].insert(node1)
    }
    
    // Return true if all elements of the input set are interconnected by repeatedly removing elements _not_ common to
    // each and seeing if any were removed.
    func isInterconnected(_ input: Set<String>) -> Bool {
        var interconnected = input
        
        for item in input {
            var reciprocalConnections = self.nodes[item]!
            reciprocalConnections.insert(item)
            
            interconnected = interconnected.intersection(reciprocalConnections)
            
            if interconnected.count < input.count {
                return false
            }
        }
        
        return true
    }
}

extension Set where Element == String {
    func combinations(of size: Int) -> [Set<String>] {
        guard self.count >= size else {
            return []
        }
        
        let elements = Array(self)
        var combos = [Set<String>]()
        
        func combine(_ start: Int, _ current: [String]) {
            if current.count == size {
                combos.append(Set(current))
                return
            }
            
            for i in start..<elements.count {
                var nextCombination = current
                nextCombination.append(elements[i])
                
                combine(i + 1, nextCombination)
            }
        }
        
        combine(0, [])
        return combos
    }
}

let graph = input(forDay: 23)
    .split(separator: "\n")
    .map { $0.split(separator: "-") }
    .reduce(into: Graph()) { graph, nodes in
        graph.addConnection(String(nodes[0]), String(nodes[1]))
    }

func partOne() -> Int {
    var lans = Set<Set<String>>()
    
outer:
    for (from, to) in graph.nodes {
        var lan = to
        lan.insert(from)
        
        if lan.count < 3 {
            continue
        }
        
        // I had a much more primitive way of doing this before part two where I was checking individual triplets of
        // nodes. It worked fine, but this is much nicer.
        for combo in lan.combinations(of: 3) {
            if graph.isInterconnected(combo) && combo.contains(where: { $0.first == "t" }) {
                lans.insert(combo)
            }
        }
    }
    
    return lans.count
}

func partTwo() -> String {
    var largestLan = Set<String>()
    
outer:
    for (from, to) in graph.nodes {
        var lan = to
        lan.insert(from)
        
        for i in (1..<lan.count).reversed() {
            // No point checking combinations shorter than the largest one we've seen
            if i <= largestLan.count {
                continue outer
            }
            
            for combo in lan.combinations(of: i) {
                // We're starting largest combo first, so as soon as we find one we know it's the largest across all
                // nodes in this network
                if graph.isInterconnected(combo) {
                    largestLan = combo
                    continue outer
                }
            }
        }
    }

    return Array(largestLan).sorted().joined(separator: ",")
}

print(partOne())
print(partTwo())
