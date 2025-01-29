import Foundation

let codes = input(forDay: 21)
    .split(separator: "\n")
    .map {
        $0.split(separator: "").map { key in
            if key == "A" {
                return KeyPadButton.activate
            }
            
            return KeyPadButton(rawValue: Int(key)!)!
        }
    }

typealias Coordinate = (x: Int, y: Int)

protocol Locatable {
    var coord: Coordinate { get }
}

enum KeyPadButton: Int, Locatable, CustomStringConvertible {
    case zero = 0, one, two, three, four, five, six, seven, eight, nine, activate
    
    var coord: Coordinate {
        switch self {
        case .zero:     (1, 3)
        case .one:      (0, 2)
        case .two:      (1, 2)
        case .three:    (2, 2)
        case .four:     (0, 1)
        case .five:     (1, 1)
        case .six:      (2, 1)
        case .seven:    (0, 0)
        case .eight:    (1, 0)
        case .nine:     (2, 0)
        case .activate: (2, 3)
        }
    }
    
    var description: String {
        switch self {
        case .zero:     "0"
        case .one:      "1"
        case .two:      "2"
        case .three:    "3"
        case .four:     "4"
        case .five:     "5"
        case .six:      "6"
        case .seven:    "7"
        case .eight:    "8"
        case .nine:     "9"
        case .activate: "A"
        }
    }
}

enum DirectionPadButton: Locatable, CustomStringConvertible {
    case left, down, right, up, activate
    
    var coord: Coordinate {
        switch self {
        case .left:     (0, 1)
        case .down:     (1, 1)
        case .right:    (2, 1)
        case .up:       (1, 0)
        case .activate: (2, 0)
        }
    }
    
    var description: String {
        switch self {
        case .left:     "<"
        case .right:    ">"
        case .up:       "^"
        case .down:     "v"
        case .activate: "A"
        }
    }
}

protocol Pad<ButtonType> {
    associatedtype ButtonType: Locatable
    
    var position: Coordinate { get set }
    
    func mustMoveXFirst(yDiff: Int) -> Bool
    func mustMoveYFirst(xDiff: Int) -> Bool
}

extension Pad {
    mutating func move(to target: Coordinate) -> [[DirectionPadButton]] {
        let p = presses(to: target)
        position = target
        
        return p
    }
    
    // Returns an array of all possibly optimal legal presses that will get from current position to target
    func presses(to target: Coordinate) -> [[DirectionPadButton]] {
        let xDiff = target.x - position.x
        let yDiff = target.y - position.y
        
        let xMoves = [DirectionPadButton](repeating: xDiff < 0 ? .left : .right, count: abs(xDiff))
        let yMoves = [DirectionPadButton](repeating: yDiff < 0 ? .up : .down, count: abs(yDiff))
        
        let xFirst = [xMoves + yMoves + [.activate]]
        let yFirst = [yMoves + xMoves + [.activate]]
        
        // Moving all XXYY will _always_ be faster than XYXY because the further pads can just press activate again.
        // However it would seem sometimes one is faster than the other in cases where both are possible.
        if mustMoveXFirst(yDiff: yDiff) {
            return xFirst
        } else if mustMoveYFirst(xDiff: xDiff) {
            return yFirst
        }
        
        return xFirst + yFirst
    }
}

struct KeyPad: Pad {
    typealias ButtonType = KeyPadButton
    
    var position = KeyPadButton.activate.coord
    
    func mustMoveXFirst(yDiff: Int) -> Bool {
        // The most we can move in the y direction from these keys without moving over the blank space
        let yThresholds = [
            KeyPadButton.one:   0,
            KeyPadButton.four:  1,
            KeyPadButton.seven: 2,
        ]
        
        for (button, threshold) in yThresholds {
            if position == button.coord && yDiff > threshold {
                return true
            }
        }
        
        return false
    }
    
    func mustMoveYFirst(xDiff: Int) -> Bool {
        return position == KeyPadButton.zero.coord && xDiff < 0 || position == KeyPadButton.activate.coord && xDiff < -1
    }
}

struct RobotDirectionPad: Pad {
    typealias ButtonType = DirectionPadButton
    
    var position = DirectionPadButton.activate.coord
    
    func mustMoveXFirst(yDiff: Int) -> Bool {
        return position == DirectionPadButton.left.coord
    }
    
    func mustMoveYFirst(xDiff: Int) -> Bool {
        return position == DirectionPadButton.up.coord && xDiff < 0
        || position == DirectionPadButton.activate.coord && xDiff < -1
    }
}

// The pads need to retain state across moves and I cba with inout params. Values are set in the part one and two funcs
var doorPad: KeyPad!
var robotPads: [RobotDirectionPad]!

// I am always sort of amazed that memoisation for this sort of problem not only works but works _insanely_ well
var memoCache: [[DirectionPadButton]: [Int: Int]]!

func make(moves: [DirectionPadButton], onPad index: Int = 0) -> Int {
    if let cached = memoCache[moves]?[index] {
        return cached
    }
    
    if index > robotPads.indices.last! {
        return moves.count
    }
    
    var moveCount = 0
    
    for target in moves {
        moveCount += robotPads[index]
            .move(to: target.coord)
            .map { make(moves: $0, onPad: index + 1) }
            .min()!
    }
    
    memoCache[moves, default: [Int: Int]()][index] = moveCount
    
    return moveCount
}

func calculateComplexity(of codes: [[KeyPadButton]]) -> Int {
    var complexity = 0
    
    for code in codes {
        var moveCount = 0
        
        for digit in code {
            moveCount += doorPad.move(to: digit.coord).map { make(moves: $0) }.min()!
        }
        
        complexity += moveCount * Int(code.map { $0.description }.dropLast().joined())!
    }
    
    return complexity
}

func partOne() -> Int {
    doorPad = KeyPad()
    robotPads = [RobotDirectionPad](repeating: RobotDirectionPad(), count: 2)
    memoCache = [[DirectionPadButton]: [Int: Int]]()
    
    return calculateComplexity(of: codes)
}

func partTwo() -> Int {
    doorPad = KeyPad()
    robotPads = [RobotDirectionPad](repeating: RobotDirectionPad(), count: 25)
    memoCache = [[DirectionPadButton]: [Int: Int]]()
    
    return calculateComplexity(of: codes)
}

print(partOne())
print(partTwo())
