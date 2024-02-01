file = File.open("day10.txt")

# `exclude` indicates which direction we want to exclude even if there's a pipe there.
Location = Struct.new(:row, :col, :exclude)

coords = Location.new(-1, -1, 'C')
$lines = file.readlines.map(&:chomp)

# Start by finding S
$lines.each_with_index { |val, index|
    col = val.index('S')
    if col != nil then
        coords.row = index
        coords.col = col
        break
    end
}

def find_adj(coords)
    adj = []
    if coords.exclude != 'U' and coords.row != 0 then
        up = $lines[coords.row - 1][coords.col]
        if up == '7' or up == '|' or up == 'F' then
            adj.append(Location.new(coords.row - 1, coords.col, 'D'))
        end
    end
    if coords.exclude != 'D' and coords.row != $lines.length() - 1 then
        down = $lines[coords.row + 1][coords.col]
        if down == 'J' or down == '|' or down == 'L' then
            adj.append(Location.new(coords.row + 1, coords.col, 'U'))
        end
    end
    if coords.exclude != 'L' and coords.col != 0 then
        left = $lines[coords.row][coords.col-1]
        if left == 'L' or left == '-' or left == 'F' then
            adj.append(Location.new(coords.row, coords.col - 1, 'R'))
        end
    end
    if coords.exclude != 'R' and coords.col != $lines[coords.row].length - 1 then
        right = $lines[coords.row][coords.col+1]
        if right == 'J' or right == '-' or right == '7' then
            adj.append(Location.new(coords.row, coords.col + 1, 'L'))
        end
    end
    return adj
end

def coord_eq(adj)
    return (adj[0].row == adj[1].row and adj[0].col == adj[1].col)
end

puts(coords)

# Okay excellent, now we need to traverse the loop starting at S to find where we meet again
# Fencepost because the answer can never be 1
steps = 1
adj = find_adj(coords)
puts(steps)
puts(adj)

while not coord_eq(adj) do
    adj[0] = find_adj(adj[0])[0]
    adj[1] = find_adj(adj[1])[0]

    steps += 1

    puts(steps)
    puts(adj)
end

print "Steps: " + steps.to_s
