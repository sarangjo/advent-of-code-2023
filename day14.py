#!/usr/bin/env python3


def cycle(grid, col_count):
    # Move north
    for j in range(col_count):
        destination = 0
        for i, row in enumerate(grid):
            if row[j] == 'O':
                grid[destination][j] = 'O'
                if destination != i:
                    grid[i][j] = '.'
                destination += 1
            elif row[j] == '#':
                destination = i+1

    # Move west
    for i, row in enumerate(grid):
        destination = 0
        for j, cell in enumerate(row):
            if cell == 'O':
                grid[i][destination] = 'O'
                if destination != j:
                    grid[i][j] = '.'
                destination += 1
            elif cell == '#':
                destination = j+1

    # Move south
    for j in range(col_count):
        destination = len(grid) - 1
        for inv_i, row in enumerate(reversed(grid)):
            i = len(grid) - 1 - inv_i
            if row[j] == 'O':
                grid[destination][j] = 'O'
                if destination != i:
                    grid[i][j] = '.'
                destination -= 1
            elif row[j] == '#':
                destination = i-1

    # Move east
    for i, row in enumerate(grid):
        destination = col_count - 1
        for inv_j, cell in enumerate(reversed(row)):
            j = col_count - 1 - inv_j
            if cell == 'O':
                grid[i][destination] = 'O'
                if destination != j:
                    grid[i][j] = '.'
                destination -= 1
            elif cell == '#':
                destination = j-1


def get_rock_locs(grid) -> set:
    rock_locs = set()
    for i, row in enumerate(grid):
        for j, cell in enumerate(row):
            if cell == 'O':
                rock_locs.add((i, j))

    return rock_locs


def calculate_load(rock_locs, row_count) -> int:
    return sum(row_count - row for (row, _) in rock_locs)


def main():
    """
    Big idea: the rock cycles are going to repeat, so find the repetition cycle for each rock location
    and then mod that by the total number of cycles.
    """
    grid = [list(s[:-1]) for s in open("day14.txt").readlines()]

    col_count = len(grid[0])
    cycle(grid, col_count)
    cycle_iter = 1

    full_rock_locs = [get_rock_locs(grid)]
    possible_cycle = 0

    while possible_cycle == 0:
        cycle(grid, col_count)
        cycle_iter += 1

        rock_locs = get_rock_locs(grid)

        # Okay, we have a new rock locs. What to evaluate?
        # Go back through our full rock locs list to find what our possible cycle could be
        for i in range(len(full_rock_locs)):
            if full_rock_locs[len(full_rock_locs) - i - 1] == rock_locs:
                possible_cycle = i + 1
                break

        full_rock_locs.append(rock_locs)

    print("Found cycle!", possible_cycle)

    # Consider the following sequence of rock locs. We want to chop off the first 3 because they are
    # outside the cycle. Then we can find which one within the cycle lines up with our target.
    # x y z [a b c d] [a ...
    offset = len(full_rock_locs) - possible_cycle - 1
    adjusted_target = 1000000000 - offset
    match = adjusted_target % possible_cycle
    correct_rock_locs = full_rock_locs[offset + match - 1]
    rock_load = calculate_load(correct_rock_locs, len(grid))

    print("offset", offset, "adjusted_target", adjusted_target,
          "match", match, "rock load", rock_load)


if __name__ == "__main__":
    main()
