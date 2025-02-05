import Foundation

enum GateOp: String {
    case and    = "AND"
    case or     = "OR"
    case xor    = "XOR"
    
    var function: (Int, Int) -> Int {
        switch self {
        case .and:  (&)
        case .or:   (|)
        case .xor:  (^)
        }
    }
}

struct Gate: Hashable {
    let input1: String
    let op: GateOp
    let input2: String
    let output: String
}

let valuesAndGates = input(forDay: 24).split(separator: /^\n/.anchorsMatchLineEndings())

func parseValues() -> [String: Int] {
    return valuesAndGates[0]
        .split(separator: "\n")
        .reduce(into: [String: Int]()) { map, initial in
            let parts = initial.split(separator: ": ")
            map[String(parts[0])] = Int(parts[1])!
        }
}

func parseGates() -> Set<Gate> {
    return valuesAndGates[1]
        .split(separator: "\n")
        .reduce(into: Set<Gate>()) { gates, gateString in
            let match = gateString.matches(of: /([a-z0-9]+) (AND|OR|XOR) ([a-zA-Z0-9]+) -> ([a-z0-9]+)/)[0]
            
            gates.insert(Gate(
                input1: String(match.1),
                op: GateOp(rawValue: String(match.2))!,
                input2: String(match.3),
                output: String(match.4)
            ))
        }
}

func runCircuit(values: [String: Int], gates: Set<Gate>) -> [String: Int] {
    var values = values
    var gates = gates
    
    while !gates.isEmpty {
        for gate in gates {
            guard let input1 = values[gate.input1], let input2 = values[gate.input2] else {
                continue
            }
            
            values[gate.output] = gate.op.function(input1, input2)
            gates.remove(gate)
        }
    }

    return values
}

func readValue(of wire: String, from values: [String: Int]) -> Int {
    return values
        .filter { (key: String, _: Int) in key.starts(with: wire) }
        .reduce(0) { result, kv in
            result + (kv.value << Int(kv.key.matches(of: /[a-z]+([0-9]+)/)[0].1)!)
        }
}

func partOne() -> Int {
    return readValue(of: "z", from: runCircuit(values: parseValues(), gates: parseGates()))
}

// https://www.reddit.com/r/adventofcode/comments/1hla5ql/2024_day_24_part_2_a_guide_on_the_idea_behind_the/
// https://www.reddit.com/r/adventofcode/comments/1hla5ql/comment/m3kws15/
// Thank you to /u/LxsterGames and /u/ElevatedUser, I was getting nowhere with this.

// https://en.wikipedia.org/wiki/Adder_(electronics)#Full_adder
// Full-adder logic (Cin/out are previous/next carry bit):
// z = x XOR y XOR Cin
// Cout = (x AND y) OR (Cin AND (x XOR y))
// Following this:

// Apart from the last bit (because the last bit is the carry output of the last full adder), a z output _must_ be XOR
func outputNotXor(for gate: Gate) -> Bool {
    if !gate.output.starts(with: "z") || gate.output == "z45" {
        return false
    }
    
    return gate.op != .xor
}

// If output is not z and input is not x or y (i.e. its an intermediate step), it _must_ be AND or OR
func intermediateNotAndOr(for gate: Gate) -> Bool {
    let input = String(gate.input1.first!) + String(gate.input2.first!)

    if input == "xy" || input == "yx" || gate.output.starts(with: "z") {
        return false
    }
    
    return gate.op == .xor
}

// x XOR y -> foo _must_ have a corresponding foo XOR Cin somewhere
func inputNotFedIntoXor(in gates: Set<Gate>, for gate: Gate) -> Bool {
    let input = String(gate.input1.first!) + String(gate.input2.first!)
    
    if gate.op != .xor || (input != "xy" && input != "yx") {
        return false
    }
    
    // This doesn't apply to the first bit because the first is a half-adder (no previous carry)
    if gate.input1.contains("00") || gate.input2.contains("00") {
        return false
    }
    
    for nextGate in gates {
        if nextGate == gate || (nextGate.input1 != gate.output && nextGate.input2 != gate.output) {
            continue
        }
        
        if nextGate.op == .xor {
            return false
        }
    }
    
    return true
}

// foo AND bar -> baz (where foo is not x XOR y) _must_ have a corresponding baz OR quux somewhere
func intermediateAndNotFedIntoOr(in gates: Set<Gate>, for gate: Gate) -> Bool {
    let input = String(gate.input1.first!) + String(gate.input2.first!)
    
    if gate.op != .and || (input == "xy" && input == "yx") {
        return false
    }
    
    if gate.input1.contains("00") || gate.input2.contains("00") {
        return false
    }

    for nextGate in gates {
        if nextGate == gate || (nextGate.input1 != gate.output && nextGate.input2 != gate.output) {
            continue
        }
        
        if nextGate.op == .or {
            return false
        }
    }
    
    return true
}

func partTwo() -> String {
    let gates = parseGates()
    
    return gates
        .filter { gate in
            outputNotXor(for: gate)
            || intermediateNotAndOr(for: gate)
            || inputNotFedIntoXor(in: gates, for: gate)
            || intermediateAndNotFedIntoOr(in: gates, for: gate)
        }
        .map { $0.output }
        .sorted()
        .joined(separator: ",")
}

print(partOne())
print(partTwo())
