import Foundation

let contents = input(forDay: 1)

var left = [Int]()
var right = [Int]()

for line in contents.split(separator: "\n") {
    let split = line.split(separator: "   ")
    
    left.append(Int(split[0])!)
    right.append(Int(split[1])!)
}

let totalDistance = zip(left.sorted(), right.sorted()).reduce(0) { carry, tuple in carry + abs(tuple.0 - tuple.1) }

print(totalDistance)

let freqMap = right.reduce([Int: Int]()) { map, r in
    var map = map
    map.updateValue(map[r, default: 0] + 1, forKey: r)
    
    return map
}

let totalSimilarity = left.reduce(0) { c, l in
    c + (l * freqMap[l, default: 0])
}

print(totalSimilarity)

