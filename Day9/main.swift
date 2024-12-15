import Foundation

struct File {
    let id: Int
    let size: Int
}

enum DiskEntry {
    case file(File)
    case freeSpace(size: Int)
    
    var isFile: Bool {
        switch self {
        case .file: true
        case .freeSpace: false
        }
    }
}

var diskMap = [DiskEntry]()

var currentId = 0
var lookingAtFile = true

for char in input(forDay: 9).split(separator: "") {
    if char == "\n" {
        break
    }
    
    defer {
        lookingAtFile.toggle()
    }
    
    if lookingAtFile {
        diskMap.append(.file(File(id: currentId, size: Int(char)!)))
        currentId += 1
    } else {
        let size = Int(char)!
        
        if size == 0 {
            continue
        }
        
        diskMap.append(.freeSpace(size: size))
    }
}

func partOne() -> Int {
    var diskMap = diskMap

    while true {
        let fileIndex = diskMap.lastIndex { $0.isFile }!
        let freeSpaceIndex = diskMap.firstIndex { !$0.isFile }!
        
        // We're done
        if freeSpaceIndex > fileIndex {
            break
        }
        
        guard
            case let .file(file) = diskMap[fileIndex],
            case let .freeSpace(size: availableSpace) = diskMap[freeSpaceIndex]
        else {
            exit(1)
        }

        if file.size == availableSpace {
            // Straight swap
            diskMap.swapAt(fileIndex, freeSpaceIndex)
        } else if availableSpace < file.size {
            // Fragment the file
            diskMap[freeSpaceIndex] = .file(File(id: file.id, size: availableSpace))
            diskMap[fileIndex] = .file(File(id: file.id, size: file.size - availableSpace))
        } else {
            // Fragment the free space. Pricey.
            diskMap[fileIndex] = .freeSpace(size: file.size)
            diskMap[freeSpaceIndex] = .file(File(id: file.id, size: file.size))
            diskMap.insert(.freeSpace(size: availableSpace - file.size), at: freeSpaceIndex + 1)
        }
    }
    
    return calculateChecksum(for: diskMap)
}

func partTwo() -> Int {
    var diskMap = diskMap
    var movedIds = Set<Int>()
    
    while true {
        // Find the index of the last file we haven't already looked at
        let fileIndex = diskMap.lastIndex { entry in
            guard case let .file(file) = entry else {
                return false
            }
            
            return !movedIds.contains(file.id)
        }
        
        guard let fileIndex = fileIndex, case let .file(file) = diskMap[fileIndex] else {
            // Break here because when we have no more files we've already looked at, we're done
            break
        }
        
        // The wording is a bit ambiguous but the example implies that we only look at each file once, and that if
        // sufficient space frees up after we first check, we don't revisit it.
        movedIds.insert(file.id)
        
        // Find the index of the first free space large enough to fit the file
        let freeSpaceIndex = diskMap.firstIndex { entry in
            guard case let .freeSpace(size) = entry else {
                return false
            }

            return size >= file.size
        }
        
        guard let freeSpaceIndex = freeSpaceIndex, case let .freeSpace(size: availableSpace) = diskMap[freeSpaceIndex] else {
            // Continue here as we may legit just not have the space to move it, so move onto the next file
            continue
        }
        
        // We can only move stuff to free space left of it. Feels kinda arbitrary. Not a very good defragger.
        if freeSpaceIndex > fileIndex {
            continue
        }

        // Unlike part one we will never be trying to fragment a file, so we only need to consider the case where it is
        // an exact fit, or the free space is bigger than the file. This works exactly as it did in part one.
        if file.size == availableSpace {
            // Straight swap
            diskMap.swapAt(fileIndex, freeSpaceIndex)
        } else {
            // Fragment the free space
            diskMap[fileIndex] = .freeSpace(size: file.size)
            diskMap[freeSpaceIndex] = .file(File(id: file.id, size: file.size))
            diskMap.insert(.freeSpace(size: availableSpace - file.size), at: freeSpaceIndex + 1)
        }
    }
    
    return calculateChecksum(for: diskMap)
}

func calculateChecksum(for diskMap: [DiskEntry]) -> Int {
    var checksum = 0
    var counter = 0
    
    for file in diskMap {
        switch file {
        case .file(let file):
            for _ in 0..<file.size {
                checksum += (file.id * counter)
                counter += 1
            }
        case .freeSpace(size: let size):
            counter += size
        }
    }
    
    return checksum
}

print(partOne())
print(partTwo())

