import Foundation

let contents = input(forDay: 5).split(separator: /^$/.anchorsMatchLineEndings())

// Map each page to an array of pages that must follow it (or can't precede it, if you're that way inclined)
let ruleMap = contents[0]
    .split(separator: "\n")
    .map {
        $0.split(separator: "|").map { Int($0)! }
    }
    .reduce(into: [Int: Set<Int>]()) { dict, pair in
        var s = dict[pair[0], default: Set<Int>()]
        s.insert(pair[1])
        
        dict[pair[0]] = s
    }

// Split the page lists into two arrays depending on if they're correct or not
let (correct, incorrect) = contents[1]
    .split(separator: "\n").map {
        $0.split(separator: ",").map {
            Int($0)!
        }
    }
    .reduce(into: ([[Int]](), [[Int]]())) { carry, pages in
        for i in pages.indices {
            // Get the list of pages that this page must come before...
            guard let rules = ruleMap[pages[i]] else {
                continue
            }
            
            // ...and see if we're after any of them.
            // This is so inefficient but I'm too stupid to think up a better way today.
            for j in 0..<i {
                if rules.contains(pages[j]) {
                    carry.1.append(pages)
                    return
                }
            }
        }
        
        carry.0.append(pages)
    }

func partOne() -> Int {
    return correct.reduce(0) { carry, pages in carry + pages[pages.count / 2] }
}

func partTwo() -> Int {
    return incorrect.reduce(0) { total, pages in
        var pages = pages
        
        for i in 0..<pages.count {
            guard let rules = ruleMap[pages[i]] else {
                continue
            }
            
            for j in 0..<i {
                if rules.contains(pages[j]) {
                    // Shitty bubble sort, go!
                    // I think I was supposed to realise something about the ordering being transitive meaning you only
                    // need a single pass through but actually I was just surprised that it worked as-is.
                    pages.swapAt(i, j)
                }
            }
        }
        
        return total + pages[pages.count / 2]
    }
}

print(partOne())
print(partTwo())
