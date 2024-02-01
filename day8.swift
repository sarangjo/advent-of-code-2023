import Foundation

func part1(_ input: String) -> Int {
    let lines = input.split(separator: "\n")
    // First line is the instruction
    let instructions = lines[0]

    var connections: [String: (String, String)] = [:]

    // Build graph
    // Start at 1 because the empty line is ignored by Swift
    for line in lines[1...] {
        let src = String(line.prefix(3))
        let left = String(line[line.index(line.startIndex, offsetBy: 7)..<line.index(line.startIndex, offsetBy: 10)])
        let right = String(line[line.index(line.startIndex, offsetBy: 12)..<line.index(line.startIndex, offsetBy: 15)])
        connections[src] = (left, right)
    }

    // Count steps
    var steps = 0
    var curInstr = 0
    var loc = "AAA"
    while loc != "ZZZ" {
        let (l, r) = connections[loc]!
        let dir = instructions[instructions.index(instructions.startIndex, offsetBy: curInstr)]

        loc = dir == "L" ? l : r

        curInstr = (curInstr + 1) % instructions.count
        steps+=1
    }

    return steps
}

func gcd(_ n1: Int, _ n2: Int) -> Int {
    var a = 0
    var b = max(n1, n2)
    var r = min(n1, n2)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

func lcm(_ n1: Int, _ n2: Int) -> Int {
    return n1 * n2 / gcd(n1, n2)
}

func lcm(_ arr: [Int]) -> Int {
    var nums = arr

    if nums.count < 2 {
        return 1
    }

    var the_lcm = 1

    var n1 = nums.removeFirst()
    var n2 = nums.removeFirst()

    while true {
        the_lcm = lcm(n1, n2)

        if nums.isEmpty {
            break
        }

        n1 = the_lcm
        n2 = nums.removeFirst()
    }

    return the_lcm
}

// Use LCM to calculate cycle
func part2(_ input: String) -> Int {
    let lines = input.split(separator: "\n")
    // First line is the instruction
    let instructions = lines[0]

    var starts: [String] = []
    var connections: [String: (String, String)] = [:]

    // Build graph
    // Start at 1 because the empty line is ignored by Swift
    for line in lines[1...] {
        let src = String(line.prefix(3))
        let left = String(line[line.index(line.startIndex, offsetBy: 7)..<line.index(line.startIndex, offsetBy: 10)])
        let right = String(line[line.index(line.startIndex, offsetBy: 12)..<line.index(line.startIndex, offsetBy: 15)])
        connections[src] = (left, right)

        if src[src.index(before: src.endIndex)] == "A" {
            starts.append(src)
        }
    }

    // Count steps
    var stepCounts: [Int] = []

    for var loc in starts {
        var steps = 0
        var curInstr = 0
        while loc[loc.index(before: loc.endIndex)] != "Z" {
            let (l, r) = connections[loc]!
            let dir = instructions[instructions.index(instructions.startIndex, offsetBy: curInstr)]

            loc = dir == "L" ? l : r

            curInstr = (curInstr + 1) % instructions.count
            steps+=1
        }
        stepCounts.append(steps)
    }

    return lcm(stepCounts)
}

var file = "day8.txt"
var input = try String(contentsOfFile: file, encoding: .utf8)
print("part 1 steps: \(part1(input))")
print("part 2 steps: \(part2(input))")
