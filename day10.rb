require "set"

file = File.open("sample10.txt")

# `from` indicates which direction came from
Location = Struct.new(:row, :col, :from)

$lines = file.readlines.map(&:chomp)

def go_in_dir(loc, dir)
    if dir == 'U' then
        return Location.new(loc.row - 1, loc.col, 'D')
    elsif dir == 'D' then
        return Location.new(loc.row + 1, loc.col, 'U')
    elsif dir == 'L' then
        return Location.new(loc.row, loc.col - 1, 'R')
    else # R
        return Location.new(loc.row, loc.col + 1, 'L')
    end
end

def leave_start(loc)
    adj = []
    if loc.row != 0 and '7|F'.include?($lines[loc.row - 1][loc.col]) then
        adj.append(go_in_dir(loc, 'U'))
    end
    if loc.row != $lines.length() - 1 and 'J|L'.include?($lines[loc.row + 1][loc.col]) then
        adj.append(go_in_dir(loc, 'D'))
    end
    if loc.col != 0 and 'L-F'.include?($lines[loc.row][loc.col-1]) then
        adj.append(go_in_dir(loc, 'L'))
    end
    if loc.col != $lines[loc.row].length - 1 and 'J-7'.include?($lines[loc.row][loc.col+1]) then
        adj.append(go_in_dir(loc, 'R'))
    end
    return adj
end

$follow_pipe = {
    '|' => ['U', 'D'],
    '-' => ['L', 'R'],
    'L' => ['U', 'R'],
    'J' => ['U', 'L'],
    '7' => ['D', 'L'],
    'F' => ['D', 'R'],
}

# Follow the pipe, avoiding loc.from
def find_next(loc)
    dirs = $follow_pipe[$lines[loc.row][loc.col]]
    return go_in_dir(loc, dirs[0] == loc.from ? dirs[1] : dirs[0])
end

def loc_eq(locs)
    return (locs[0].row == locs[1].row and locs[0].col == locs[1].col)
end

# Start by finding S
$start = Location.new(-1, -1, 'C')
$lines.each_with_index { |val, index|
    col = val.index('S')
    if col != nil then
        $start.row = index
        $start.col = col
        break
    end
}

def part_1
    # Okay excellent, now we need to traverse the loop starting at S to find where we meet again
    # Fencepost because the answer can never be 1
    steps = 1
    locs = leave_start($start)

    while not loc_eq(locs) do
        locs[0] = find_next(locs[0])
        locs[1] = find_next(locs[1])

        steps += 1
    end

    print "Steps: " + steps.to_s
end

def part_2
    # First, we collect the pipe locations row-wise
    pipe = {}

    # Add start
    locs = leave_start($start)

    # Based on locs, figure out what start should be
    dirs = locs.map

    pipe[locs[0].row] = pipe.has_key?(locs[0].row) ? pipe[locs[0].row].add(locs[0].col) : SortedSet.new([locs[0].col])
    pipe[locs[1].row] = pipe.has_key?(locs[1].row) ? pipe[locs[1].row].add(locs[1].col) : SortedSet.new([locs[1].col])

    pipe[$start.row] = SortedSet.new([$start.col])

    while not loc_eq(locs) do
        locs[0] = find_next(locs[0])
        locs[1] = find_next(locs[1])

        pipe[locs[0].row] = pipe.has_key?(locs[0].row) ? pipe[locs[0].row].add(locs[0].col) : SortedSet.new([locs[0].col])
        pipe[locs[1].row] = pipe.has_key?(locs[1].row) ? pipe[locs[1].row].add(locs[1].col) : SortedSet.new([locs[1].col])
    end

    pipe = pipe.sort_by { |key| key }.to_h

    # Now we evaluate how many spaces are in between by row
    inside_spots = 0
    is_first = true
    row_count = 0
    pipe.each { |key, row|
        if is_first then
            is_first = false
            next
        end

        inside = false
        prev = -1
        row.each { |col|
            if inside then
                row_count += (col - prev - 1)
            end

            inside = !inside
            prev = col
        }

        inside_spots += row_count
        row_count = 0
    }

    # Remove the last row
    inside_spots -= row_count

    puts "Inside spots: " + inside_spots.to_s
end

# part_1
part_2
