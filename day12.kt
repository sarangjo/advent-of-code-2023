import java.io.File

fun part1(fn: String): Int {
    var sum = 0

    val f = File(fn)
    f.forEachLine(action = fun(line: String) {
        // Split into configuration and mapping
        val parts = line.split(" ")
        val springs = parts[0]
        val segments = parts[1].split(",").map { it.toInt() }

        println("Line: $line")
        val opts = processLine("", springs, segments.toMutableList())
        println(opts)

        sum += opts
    })

    return sum
}

// TODO maybe use an ArrayDeque instead of a List
fun processLine(parsed: String, line: String, segments: MutableList<Int>): Int {
    // Recursively process line based on whether this is a ? or not
    // What if we run out of segments?
    if (segments.size == 0) {
        if (!line.contains('#')) {
            // println(parsed + line)
            return 1
        }
        return  0
    }
    val curSegment = segments[0]
    var sum = 0

    if (line.length < curSegment) {
        return 0
    }
    val potentialLineSegment = line.substring(0, curSegment)
    if (!potentialLineSegment.contains('.')) {
        // Okay, our segment matches. But we can only move forward if the next element is not '#'.
        if (line.length == curSegment || line[curSegment] != '#') {
            // If we're not at the end, we additionally consume an extra character
            val notEnd = line.length != curSegment

            // This segment is consumed! Onward and upward
            segments.removeFirst()
            sum += processLine(parsed + "#".repeat(curSegment) + (if (notEnd) '.' else ""),
                    line.substring(curSegment + (if (notEnd) 1 else 0)),
                    segments)
            // sum += processLine(consumedParsed, line.substring(consumedCurSegment), segments)
            segments.add(0, curSegment)
        }
    }

    // Try not inserting and move along
    if (line[0] != '#') {
        sum += processLine(parsed + '.', line.substring(1), segments)
    }

    return sum
}

fun main() {
    println("part1: " + part1("day12.txt"))
}
