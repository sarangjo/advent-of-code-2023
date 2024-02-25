import java.io.File

fun part1(fn: String): Long {
    var sum: Long = 0

    val f = File(fn)
    f.forEachLine(action = fun(line: String) {
        // Split into configuration and mapping
        val parts = line.split(" ")
        val springs = parts[0]
        val segments = parts[1].split(",").map { it.toInt() }

        sum += processLine(springs, segments.toMutableList())
    })

    return sum
}

fun part2(fn: String): Long {
    var sum: Long = 0

    val f = File(fn)
    f.forEachLine(action = fun(line: String) {
        // Split into configuration and mapping
        val parts = line.split(" ")
        val springs = parts[0]
        val segments = parts[1].split(",").map { it.toInt() }

        sum += processLine(List(5) { springs }.joinToString("?"), MutableList(5) { segments }.flatten().toMutableList())
    })

    return sum
}

fun processLine(line: String, segments: MutableList<Int>, parsed: String = "", known: MutableMap<String, MutableMap<List<Int>, Long>> = mutableMapOf()): Long {
    // Recursively process line based on whether this is a ? or not
    // What if we run out of segments?
    if (segments.size == 0) {
        if (!line.contains('#')) {
            return 1
        }
        return 0
    }

    // Do we have enough space for our remaining segments?
    val remainingSegmentCount = segments.sum() + segments.size - 1
    if (line.length < remainingSegmentCount) {
        return 0
    }

    // Check memoization
    if (known[line]?.contains(segments.toList()) == true) {
        return known[line]?.get(segments) ?: 0
    }

    val curSegment = segments[0]
    var sum: Long = 0

    // Can we use this segment?
    val potentialLineSegment = line.substring(0, curSegment)
    if (!potentialLineSegment.contains('.')) {
        // Okay, our segment matches. But we can only move forward if the next element is not '#'.
        if (line.length == curSegment || line[curSegment] != '#') {
            // If we're not at the end, we additionally consume an extra character
            val notEnd = line.length != curSegment

            // This segment is consumed! Onward and upward
            segments.removeFirst()
            sum += processLine(line.substring(curSegment + (if (notEnd) 1 else 0)),
                    segments, parsed + "#".repeat(curSegment) + (if (notEnd) '.' else ""), known)
            segments.add(0, curSegment)
        }
    }

    // Try not inserting and move along
    if (line[0] != '#') {
        sum += processLine(line.substring(1), segments, "$parsed.", known)
    }

    // Memoize
    if (!known.contains(line)) {
        known[line] = mutableMapOf()
    }
    known[line]!![segments] = sum

    return sum
}

fun main() {
    println("part1: " + part1("day12.txt"))
    println("part2: " + part2("day12.txt"))
}
