import Foundation

let contents = input(forDay: 4)

func partOne() -> Int {
    var total = 0
    
    let lines = pad(input: contents
        .split(separator: "\n")
        .map { $0.split(separator: "").map { String($0) } })
    
    for y in 3..<lines.count - 3 {
        for x in 3..<lines[0].count - 3 {
            if lines[y][x] != "X" {
                continue
            }
            
            total += countXmas(in: lines, x: x, y: y)
        }
    }

    return total
}

func partTwo() -> Int {
    var total = 0
    
    let lines = pad(input: contents
        .split(separator: "\n")
        .map { $0.split(separator: "").map { String($0) } })
    
    for y in 3..<lines.count - 3 {
        for x in 3..<lines[0].count - 3 {
            if lines[y][x] != "A" {
                continue
            }
            
            if countMasInX(in: lines, x: x, y: y) {
                total += 1
            }
        }
    }

    return total
}


// Pad the array with 3 empty rows and columns each side so we can be lazy and skip bounds checking
func pad(input: [[String]]) -> [[String]] {
    var input = input
    
    let topAndBottom = Array(repeating: Array(repeating: " ", count: input[0].count), count: 3)
    let leftAndRight = Array(repeating: " ", count: 3)
    
    input = topAndBottom + input + topAndBottom
    
    return input.map { leftAndRight + $0 + leftAndRight }
}

func countXmas(in arr: [[String]], x: Int, y: Int) -> Int {
    var count = 0
    
    // Look for
    // S  S  S
    //  A A A
    //   MMM
    // SAMXMAS
    //   MMM
    //  A A A
    // S  S  S
    // from each X
    
    // Horizontal
    if arr[y][x - 1] == "M" && arr[y][x - 2] == "A" && arr[y][x - 3] == "S" {
        count += 1
    }
    
    if arr[y][x + 1] == "M" && arr[y][x + 2] == "A" && arr[y][x + 3] == "S" {
        count += 1
    }
    
    // Vertical
    if arr[y - 1][x] == "M" && arr[y - 2][x] == "A" && arr[y - 3][x] == "S" {
        count += 1
    }
    
    if arr[y + 1][x] == "M" && arr[y + 2][x] == "A" && arr[y + 3][x] == "S" {
        count += 1
    }

    // Diagonal
    if arr[y - 1][x - 1] == "M" && arr[y - 2][x - 2] == "A" && arr[y - 3][x - 3] == "S" {
        count += 1
    }
    
    if arr[y - 1][x + 1] == "M" && arr[y - 2][x + 2] == "A" && arr[y - 3][x + 3] == "S" {
        count += 1
    }

    if arr[y + 1][x - 1] == "M" && arr[y + 2][x - 2] == "A" && arr[y + 3][x - 3] == "S" {
        count += 1
    }

    if arr[y + 1][x + 1] == "M" && arr[y + 2][x + 2] == "A" && arr[y + 3][x + 3] == "S" {
        count += 1
    }

    return count
}

func countMasInX(in arr: [[String]], x: Int, y: Int) -> Bool {
    // Same deal as part one but search for either direction of MAS in both diagonals
    if ((arr[y - 1][x - 1] == "M" && arr[y + 1][x + 1] == "S") || (arr[y - 1][x - 1] == "S" && arr[y + 1][x + 1] == "M"))
        && ((arr[y + 1][x - 1] == "M" && arr[y - 1][x + 1] == "S") || (arr[y + 1][x - 1] == "S" && arr[y - 1][x + 1] == "M")) {
        return true
    }
    
    return false
}

print(partOne())
print(partTwo())
