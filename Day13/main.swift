import Foundation

struct Coordinate {
    let x: Double
    let y: Double
}

struct Input {
    let aPress: Coordinate
    let bPress: Coordinate
    let prize: Coordinate
}

let inputs = input(forDay: 13)
    .split(separator: /^\n/.anchorsMatchLineEndings())
    .map { set in
        let lines = set.components(separatedBy: "\n")
        
        return Input(aPress: parseButton(lines[0]),
                     bPress: parseButton(lines[1]),
                     prize: parsePrize(lines[2]))
    }

func parseButton(_ line: String) -> Coordinate {
    let match = line.matches(of: /X\+([0-9]+), Y\+([0-9]+)/)[0]
    
    return Coordinate(x: Double(match.1)!, y: Double(match.2)!)
}

func parsePrize(_ line: String) -> Coordinate {
    let match = line.matches(of: /X=([0-9]+), Y=([0-9]+)/)[0]
    
    return Coordinate(x: Double(match.1)!, y: Double(match.2)!)
}

// Had a minor breakdown trying to remember the high school level algebra needed for this, but we have two equations
// with two unknowns.
//
// A -> count of A presses, B -> count of B presses
// ax, ay, bx, by -> amount moved in each direction by each press
// px, py -> prize location
//
// Two equations:
// A.ax + B.bx = px
// A.ay + B.by = py
//
// Rearrange both in terms of B:
// B = px - A.ax / bx
// B = py - A.ay / by
// px - A.ax / bx = py - A.ay / by
//
// Rearrange the resulting equation in terms of A:
// px - A.ax = bx(py - A.ay / by)
// by.px - by.A.ax = bx.py - bx.A.ay
// by.px = bx.py + by.A.ax - bx.A.ay
// by.px - bx.py = by.A.ax - bx.A.ay
// by.px - bx.py = A(by.ax - bx.ay)
// A = (by.px - bx.py) / (by.ax - bx.ay)
//
// Then solve A and sub into one of the equations for B
func solve(_ input: Input) -> (a: Double, b: Double)? {
    let a = ((input.bPress.y * input.prize.x) - (input.bPress.x * input.prize.y))
        / ((input.bPress.y * input.aPress.x) - (input.bPress.x * input.aPress.y))
    
    let b = (input.prize.x - (a * input.aPress.x)) / (input.bPress.x)
    
    // Non-integer solution == no valid solution
    if floor(a) != a || floor(b) != b {
        return nil
    }

    return (a, b)
}

func partOne() -> Int {
    var total = 0

    for input in inputs {
        guard let (a, b) = solve(input) else {
            continue
        }
        
        // A costs three tokens, I can only assume to test reading comprehension
        total += Int((3 * a) + b)
    }
    
    return total
}

let fuckYouFactor: Double = 10_000_000_000_000

func partTwo() -> Int {
    var total = 0
    
    for input in inputs {
        let input = Input(aPress: input.aPress,
                          bPress: input.bPress,
                          prize: Coordinate(x: input.prize.x + fuckYouFactor, y: input.prize.y + fuckYouFactor))
        
        guard let (a, b) = solve(input) else {
            continue
        }
        
        total += Int((3 * a) + b)
    }
    
    return total
}

print(partOne())
print(partTwo())
