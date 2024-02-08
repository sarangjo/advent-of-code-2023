require "set"

file = File.open("day10.txt")

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
    '|' => ['D', 'U'],
    '-' => ['L', 'R'],
    'L' => ['R', 'U'],
    'J' => ['L', 'U'],
    '7' => ['D', 'L'],
    'F' => ['D', 'R'],
}

def invert(dir)
    if dir == 'U'
        return 'D'
    elsif dir == 'D'
        return 'U'
    elsif dir == 'L'
        return 'R'
    elsif dir == 'R'
        return 'L'
    end
end

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

    puts "Part 1: " + steps.to_s
end

def add_to_pipe(pipe, row, col, symbol)
    pipe[row] = pipe.has_key?(row) ? pipe[row].add([col, symbol]) : [[col, symbol]].to_set
end

def build_pipe()
    # First, we collect the pipe locations row-wise
    pipe = {}

    # Add start
    locs = leave_start($start)

    # Based on locs, figure out what start should be.
    # First, extract the "from" for the two first steps.
    dirs = locs.map { |loc| invert(loc.from) }.sort()

    deciphered_start = $follow_pipe.find{ |key, val| val == dirs }

    add_to_pipe(pipe, $start.row, $start.col, deciphered_start[0])
    locs.each { |loc| add_to_pipe(pipe, loc.row, loc.col, $lines[loc.row][loc.col]) }

    while not loc_eq(locs) do
        locs[0] = find_next(locs[0])
        locs[1] = find_next(locs[1])

        locs.each { |loc| add_to_pipe(pipe, loc.row, loc.col, $lines[loc.row][loc.col]) }
    end

    return pipe.sort_by { |key| key }.to_h
end

def count_spots(pipe)
    # Now we evaluate how many spaces are in between by row
    inside_spots = 0
    pipe.each { |key, row|
        row = row.sort_by { |pair| pair[0] }

        state = :out
        prev = -1
        row.each { |pair|
            col, val = pair

            if state == :in then
                inside_spots += (col - prev - 1)
            end

            if val == '|'
                state = state == :out ? :in : :out
            # Corners
            elsif val == 'F'
                state = state == :out ? :up : :down
            elsif val == 'L'
                state = state == :out ? :down : :up
            elsif val == '7'
                state = state == :up ? :out : :in
            elsif val == 'J'
                state = state == :up ? :in : :out
            end

            prev = col
        }
    }

    return inside_spots
end

def part_2
    pipe = build_pipe()
    inside_spots = count_spots(pipe)

    puts "Part 2: " + inside_spots.to_s
end

part_1
part_2
