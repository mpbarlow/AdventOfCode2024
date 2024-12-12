import Foundation

// Convert the input into an [[Int]] where in each [Int] the first digit is the total and
// the remaining are the operands.
let equations = input(forDay: 7)
    .split(separator: "\n")
    .map { line in
        let parts = line.split(separator: ": ")
        return [Int(parts[0])!] + parts[1].split(separator: " ").map { Int($0)! }
    }

struct Operand {
    let value: Int
    let next: ArraySlice<Int>
    let operators: [(Int, Int) -> Int]
    
    func seek(_ goal: Int) -> Bool {
        // All the operators make the numbers go bigger so while this is a pretty crappy
        // optimisation I guess it does more than nothing.
        if value > goal {
            return false
        }
        
        if next.isEmpty {
            return value == goal
        }
        
        for op in operators {
            let index = next.indices.first!
            if Self(value: op(value, next[index]), next: next[(index + 1)...], operators: operators).seek(goal) {
                return true
            }
        }
        
        return false
    }
}

func cc(lhs: Int, rhs: Int) -> Int {
    return Int(String(lhs) + String(rhs))!
}

// In the interest of transparency I never thought of using a tree until I saw a comment on reddit.
// My original attempt for part one used powers of two and bit-shifting to generate all combinations of
// + and *, which worked great until part two added a third operator and then it didn't.
func partOne() -> Int {
    return equations.reduce(0) { carry, eq in
        var eq = eq
        let goal = eq.removeFirst()

        if Operand(value: eq[0], next: eq[1...], operators: [(+), (*)]).seek(goal) {
            return carry + goal
        }
        
        return carry
    }
}

func partTwo() -> Int {
    return equations.reduce(0) { carry, eq in
        var eq = eq
        let goal = eq.removeFirst()

        if Operand(value: eq[0], next: eq[1...], operators: [(+), (*), cc]).seek(goal) {
            return carry + goal
        }
        
        return carry
    }
}

print(partOne())
print(partTwo())
