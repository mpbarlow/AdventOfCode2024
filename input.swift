import Foundation

func input(forDay day: Int) -> String {
    let file = FileManager.default.currentDirectoryPath + "/Day" + String(day) + "/input.txt"
    let contents = try? String(contentsOfFile: file, encoding: .utf8)

    guard let contents = contents else {
        exit(1)
    }

    return contents
}
