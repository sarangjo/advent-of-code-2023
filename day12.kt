import java.io.File

fun part1(): Int {
    var sum = 0

    val f = File("sample12.txt")
    f.forEachLine(action = fun(line: String) {
        // Split into configuration and mapping
        val parts = line.split(" ")
        val springs = parts[0]
        val segments = parts[1].split(",").map { it.toInt() }

        println(springs)
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
        return if (line.contains('#')) 0 else 1
    }
    var curSegment = segments[0]

    var sum = 0

    if (line.length < curSegment) {
        return 0
    }
    val potentialLineSegment = line.substring(0, curSegment)
    if (!potentialLineSegment.contains('.')) {
        // We are now consuming the next segment!
        var consumedParsed = parsed
        var consumedCurSegment = curSegment

        // Add the consumed segment into parsed as consumedParsed
        for (i in 0 until consumedCurSegment) {
            consumedParsed += '#'
        }

        // Either we're at the end or the next one is a '.'
        if (line.length != consumedCurSegment) {
            // If we're not at the end, that means we need the next character to be a '.'
            if (line[consumedCurSegment] == '#') {
                // Ruh-roh, we're forced to have a broken one? Failed attempt
                return 0
            }
            consumedParsed += '.'
            consumedCurSegment++
        }

        // This segment is consumed! Onward and upward
        segments.removeFirst()
        sum += processLine(consumedParsed, line.substring(consumedCurSegment), segments)
        segments.add(0, curSegment)
    }
    // Always try not inserting and move along
    sum += processLine(parsed + '.', line.substring(1), segments)

    return sum
}

fun main() {
    println("part1: " + part1())
}
