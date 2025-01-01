import Foundation


let maxX = 100
let maxY = 102

struct Robot {
    var x: Int
    var y: Int
    
    let vX: Int
    let vY: Int
    
    mutating func tick() {
        var newX = x + vX
        var newY = y + vY
        
        // + 1 because the maxes are max indices, not numbers of positions to wrap over
        if newX < 0 {
            newX += maxX + 1
        } else if newX > maxX {
            newX -= maxX + 1
        }
        
        if newY < 0 {
            newY += maxY + 1
        } else if newY > maxY {
            newY -= maxY + 1
        }

        x = newX
        y = newY
    }
}

enum QuadX {
    case left, right
}

enum QuadY {
    case top, bottom
}

let robots = input(forDay: 14)
    .split(separator: "\n")
    .map { line in
        let def = line.matches(of: /p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/)[0]
        
        return Robot(x: Int(def.1)!, y: Int(def.2)!, vX: Int(def.3)!, vY: Int(def.4)!)
    }

func assignQuadrant(to robot: Robot) -> (QuadY, QuadX)? {
    // On the edge; don't count
    if robot.x == maxX / 2 || robot.y == maxY / 2 {
        return nil
    }
    
    return (robot.y < maxY / 2 ? QuadY.top : QuadY.bottom, robot.x < maxX / 2 ? QuadX.left : QuadX.right)
}

func partOne() -> Int {
    var quads = [0, 0, 0, 0]
    
    for var robot in robots {
        for _ in 0..<100 {
            robot.tick()
        }
        
        guard let (quadY, quadX) = assignQuadrant(to: robot) else {
            continue
        }
        
        switch (quadY, quadX) {
        case (.top, .left):     quads[0] += 1
        case (.top, .right):    quads[1] += 1
        case (.bottom, .left):  quads[2] += 1
        case (.bottom, .right): quads[3] += 1
        }
    }

    return quads.reduce(1, *)
}

// What the hell kind of puzzle is this? There are so many ways you could draw a Christmas tree and no clue whatsoever
// as to what you're looking for
func partTwo() -> Int {
    var robots = robots
    var secs = 0
    
    while true {
        var quads = [0, 0, 0, 0]
        var grid = Array(repeating: Array(repeating: ".", count: maxX + 1), count: maxY + 1)
        
        for i in 0..<robots.count {
            robots[i].tick()
            grid[robots[i].y][robots[i].x] = "#"
            
            guard let (quadY, quadX) = assignQuadrant(to: robots[i]) else {
                continue
            }
            
            switch (quadY, quadX) {
            case (.top, .left):     quads[0] += 1
            case (.top, .right):    quads[1] += 1
            case (.bottom, .left):  quads[2] += 1
            case (.bottom, .right): quads[3] += 1
            }
        }
        
        secs += 1
        
        // Dumb heuristic, the reference to quadrants in part one makes me think _maybe_ the tree is going to be inside
        // one quadrant in particular, and so I should look for clustering?
        let mostPopulousQuads = quads.sorted(by: >)
        
        // It ended up working out after trial and error of locating the tree in a bunch of false positives, then
        // whittling down a threshold until that was all that was returned.
        if mostPopulousQuads[0] - mostPopulousQuads[1] > 100 {
            print(grid: grid)
            
            return secs
        }
    }
}

func print(grid: [[String]]) {
    for line in grid {
        print(line.joined())
    }
}

print(partOne())
print(partTwo())
