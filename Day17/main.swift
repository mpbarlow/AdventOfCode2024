import Foundation

enum Register {
    case a, b, c
}

struct RegisterSet {
    var a: Int
    var b: Int
    var c: Int
    
    subscript(_ name: Register) -> Int {
        get {
            switch name {
            case .a: a
            case .b: b
            case .c: c
            }
        }
        set {
            switch name {
            case .a: a = newValue
            case .b: b = newValue
            case .c: c = newValue
            }
        }
    }
}

enum Operand {
    case literal(value: Int)
    case register(name: Register)
    case reserved
}

enum Instruction: Int {
    case adv = 0
    case bxl = 1
    case bst = 2
    case jnz = 3
    case bxc = 4
    case out = 5
    case bdv = 6
    case cdv = 7
}

let progDef = input(forDay: 17).split(separator: "\n")

let (a, b, c) = {
    var values = [Int]()
    
    for i in 0..<3 {
        values.append(Int(progDef[i].matches(of: /: (\d+)/)[0].1)!)
    }
    
    return (values[0], values[1], values[2])
}()

let program = progDef[3].matches(of: /: ([\d+,]+)/)[0].1.split(separator: ",").map { Int($0)! }

func getComboOperandValue(_ rawValue: Int, registers: RegisterSet) -> Int {
    switch rawValue {
    case 0...3: return rawValue
    case 4:     return registers[.a]
    case 5:     return registers[.b]
    case 6:     return registers[.c]
    default:
        print("Encountered invalid operand \(rawValue)")
        exit(1)
    }
}

func run(program: [Int], registers: RegisterSet) -> [String] {
    var registers = registers
    var pc = 0

    var output = [String]()
    
    while pc < program.count {
        let instr = Instruction(rawValue: program[pc])!
        let oc = pc + 1
        
        switch instr {
        case .adv:
            let operand = getComboOperandValue(program[oc], registers: registers)
            registers[.a] = registers[.a] / Int(pow(2.0, Double(operand)))
            
        case .bxl:  registers[.b] = registers[.b] ^ program[oc]
        case .bst:  registers[.b] = getComboOperandValue(program[oc], registers: registers) % 8
            
        case .jnz:
            if registers[.a] == 0 {
                break
            }
            
            pc = program[oc]
            continue
            
        case .bxc:  registers[.b] = registers[.b] ^ registers[.c]
        case .out:  output.append(String(getComboOperandValue(program[oc], registers: registers) % 8))
        case .bdv:
            let operand = getComboOperandValue(program[oc], registers: registers)
            registers[.b] = registers[.a] / Int(pow(2.0, Double(operand)))
            
        case .cdv:
            let operand = getComboOperandValue(program[oc], registers: registers)
            registers[.c] = registers[.a] / Int(pow(2.0, Double(operand)))
        }
        
        pc += 2
    }

    return output
}

func partOne() -> String {
    return run(program: program, registers: RegisterSet(a: a, b: b, c: c)).joined(separator: ",")
}

func partTwo() -> Int {
    return findSolutions().map { Int($0.map { String($0) }.joined(), radix: 8)! }.min()!
}

// This was fucking torture, I spent about six hours on this because I'm a stubborn idiot. I had something like this
// solution in hour two, but threw it away because it didn't work. Only now do I realise I was doing it backwards,
// trying to build up the answer from the least significant bits and the first output upwards, instead of the last
// output first and MSB -> LSB.
// Wasted a ton of time trying to implement a system that would guess three bits at a time from right to left, with a
// second guessing loop for the other three bits of a that can affect the output via the c = a / 2 ** b line. If I'm
// honest, I'm not fully sure why that didn't work; I think it maybe would have but I made a silly error somewhere.
//
// Anyway, explainer. The code in the loop is my specific input program implemented in Swift, minus the a = a / 8
// because that's only needed to shift the last 3 bits off a for the next iteration and we're going backwards.
// If we're outputting a number then shifting 3 bits off, we know the 3 LSBs are responsible for the first output and
// so on. So, working backwards, the 3 most significant bits produce the last output, so find all possibilities that
// produce the last output. Feed each into the next iteration that tries to guess the second to last output from the
// next 3 MSBs, and so on. Because we're working right-to-left, any values shifted into c are already accounted for --
// they might be incorrect, but that would just invalidate that particular branch of the search.
func findSolutions(octals: [Int] = [], seekIndex: Int = program.count - 1, solutions: [[Int]] = []) -> [[Int]] {
    var solutions = solutions
    
    if seekIndex < 0 {
        solutions.append(octals)
        return solutions
    }

    for guess in 0o0...0o7 {
        var octals = octals
        octals.append(guess)
        
        let a = intFrom(octals: octals)
        var b = a % 8
        b = b ^ 0b110
        let c = a / Int(pow(2.0, Double(b)))
        b = b ^ c
        b = b ^ 0b111
        
        if b % 8 == program[seekIndex] {
            solutions = solutions + findSolutions(octals: octals, seekIndex: seekIndex - 1, solutions: solutions)
        }
    }
    
    return solutions
}

func intFrom(octals: [Int]) -> Int {
    return Int(octals.map { String($0) }.joined(), radix: 8)!
}

print(partOne())
print(partTwo())
