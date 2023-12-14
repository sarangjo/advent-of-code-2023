from io import TextIOWrapper

def part1(f: TextIOWrapper):
    # Hold onto three lines at a time
    print("Line 1:", f.readline().strip())
    print("Line 2:", f.readline().strip())
    print("Line 3:", f.readline().strip())
    print("Line 4:", f.readline().strip())

def main():
    with open("sample4.txt") as f:
        part1(f)

if __name__ == "__main__":
    main()
