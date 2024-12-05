import Foundation

let contents = input(forDay: 3)

func partOne() -> Int {
    return getTotal(of: contents)
}

func partTwo() -> Int {
    var total = 0
    
    let possibleDos = contents.split(separator: "do()")
    for pd in possibleDos {
        // The next do() is guaranteed to be in a different pd, so we just need to process whatever is up to the
        // first don't() (if any)
        total += getTotal(of: String(pd.split(separator: "don't()")[0]))
    }
    
    return total
}

func getTotal(of input: String) -> Int {
    var total = 0
    
    for match in input.matches(of: /mul\((\d{1,3}),(\d{1,3})\)/) {
        total += (Int(match.1)! * Int(match.2)!)
    }

    return total
}

print(partOne())
print(partTwo())
