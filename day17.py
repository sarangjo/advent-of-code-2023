def move(pos, dir):
    if dir == 'R':
        return (pos[0], pos[1] + 1)
    elif dir == 'D':
        return (pos[0] + 1, pos[1])
    elif dir == 'L':
        return (pos[0], pos[1] - 1)
    else:  # 'U'
        return (pos[0] - 1, pos[1])


dirs = {
    'X': ['R', 'D'],
    'R': ['U', 'R', 'D'],
    'D': ['R', 'D', 'L'],
    'L': ['D', 'L', 'U'],
    'U': ['L', 'U', 'R']
}


def get_best_weight(grid, pos, path, same_dir_count, dir):
    if pos[0] < 0 or pos[0] >= len(grid) or pos[1] < 0 or pos[1] >= len(grid) or path[pos[0]][pos[1]]:
        return -1

    possible_directions = dirs[dir]
    best_weight = -1

    if pos[0] == len(grid)-1 and pos[1] == len(grid) - 1:
        return grid[pos[0]][pos[1]]

    path[pos[0]][pos[1]] = True

    for next_d in possible_directions:
        if next_d == dir:
            same_dir_count += 1
        else:
            same_dir_count = 0

        if same_dir_count >= 4:
            continue

        next_weight = get_best_weight(grid, move(
            pos, next_d), path, same_dir_count, next_d)
        if next_weight < 0:
            continue

        if best_weight < 0 or next_weight < best_weight:
            best_weight = next_weight

    path[pos[0]][pos[1]] = False

    return best_weight if best_weight < 0 else grid[pos[0]][pos[1]] + best_weight


def main():
    with open("sample17.txt") as f:
        lines = f.readlines()

    grid = [[int(c) for c in line.strip()] for line in lines]

    print(grid)

    r_weight = get_best_weight(grid, (0, 1), [[False for _ in range(
        len(grid))] for _ in range(len(grid))], 0, 'R')
    d_weight = get_best_weight(grid, (1, 0), [[False for _ in range(
        len(grid))] for _ in range(len(grid))], 0, 'D')

    print("r", r_weight, "d", d_weight)


if __name__ == "__main__":
    main()
