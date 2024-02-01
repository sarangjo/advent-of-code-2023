from io import TextIOWrapper


def part1(f: TextIOWrapper):
    # Hold three lines
    prev = ""
    cur = ""
    next = ""

    sum = 0

    cur = f.readline().strip()
    while True:
        next = f.readline().strip()

        # Go through cur and look for numbers
        now_num = 0
        start_idx = -1
        for i, c in enumerate(cur):
            if c.isnumeric():
                if start_idx == -1:
                    start_idx = i

                now_num = now_num * 10 + int(c)
            else:
                if start_idx != -1:
                    if check_symbol(prev, cur, next, start_idx, i-1):
                        sum += now_num

                    start_idx = -1

                now_num = 0

        if start_idx != -1:
            if check_symbol(prev, cur, next, start_idx, len(cur)-1):
                sum += now_num

        # Advance
        prev = cur
        cur = next

        if cur == "":
            return sum


def check_symbol(prev: str, cur: str, next: str, start, end):
    # prev[start-1:end+1], next[start-1:end+1]
    for line in [prev, next]:
        if line != "":
            for c in line[start if start == 0 else start-1:end+1 if end == len(line)-1 else end+2]:
                if not c.isnumeric() and c != ".":
                    return True

    # cur[start-1], cur[end+1],
    if start != 0:
        if not cur[start-1].isnumeric() and cur[start-1] != ".":
            return True
    if end != len(cur)-1:
        if not cur[end+1].isnumeric() and cur[end+1] != ".":
            return True


def part2(f: TextIOWrapper):
    # Hold three lines
    prev = ""
    cur = ""
    next = ""

    sum = 0

    cur = f.readline().strip()
    while True:
        next = f.readline().strip()

        # Look for gears
        for i, c in enumerate(cur):
            if c == "*":
                # Check if this is a gear
                sum += get_gear_ratio(prev, cur, next, i)

        prev = cur
        cur = next

        if cur == "":
            return sum


def get_gear_ratio(prev: str, cur: str, next: str, i):
    # How many numbers are adjacent to cur[i]?
    nums = []

    for line in [prev, cur, next]:
        # Start with prev[i-1] and back
        num = ""
        j = i-1
        while j >= 0:
            if line[j].isnumeric():
                num = line[j] + num
            else:
                break
            j -= 1

        # Then check line[i]
        if line[i].isnumeric():
            num += line[i]
        else:
            if num != "":
                nums.append(num)
                num = ""

        # Finally line[i+1] an onward
        j = i+1
        while j < len(line):
            if line[j].isnumeric():
                num += line[j]
            else:
                break
            j += 1

        if num != "":
            nums.append(num)

    if len(nums) == 2:
        return int(nums[0]) * int(nums[1])
    return 0


def main():
    with open("day3.txt") as f:
        print("part 1:", part1(f))

    with open("day3.txt") as f:
        print("part 2:", part2(f))


if __name__ == "__main__":
    main()
