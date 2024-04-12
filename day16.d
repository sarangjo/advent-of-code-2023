import std.stdio;
import std.exception;
import std.container : DList;
import std.typecons;
import std.format;

class GridLoc {
    int row, col;

    this(int r, int c) {
        row = r;
        col = c;
    }

    override size_t toHash() {
        return row * 200 + col * 10;
    }

    override bool opEquals(Object o) {
        GridLoc oth = cast(GridLoc) o;
        return oth && row == oth.row && col == oth.col;
    }
}

class Beam : GridLoc {
    char dir;

    this(int r, int c, char d) {
        super(r, c);
        dir = d;
    }

    override size_t toHash() {
        return super.toHash() + (cast(int)dir) * 3000;
    }

    override bool opEquals(Object o) {
        Beam oth = cast(Beam) o;
        return oth && row == oth.row && col == oth.col && dir == oth.dir;
    }

    override string toString() {
        return format("(%d,%d,%c)", this.row, this.col, this.dir);
    }
};

string[] parse_grid(string filename) {
    auto file = File(filename, "r");

    string[] grid = new string[0];
    string line;
    while ((line = file.readln()) !is null) {
        grid ~= line;
    }

    return grid;
}

ulong part1(string filename) {
    string[] grid = parse_grid(filename);

    auto beams = DList!Beam(new Beam(0, 0, 'r'));
    bool[Beam] energized;

    void add_next(Beam beam) {
        Beam new_beam = null;
        if (beam.dir == 'u' && beam.row > 0) {
            new_beam = new Beam(beam.row - 1, beam.col, beam.dir);
        } else if (beam.dir == 'l' && beam.col > 0) {
            new_beam = new Beam(beam.row, beam.col - 1, beam.dir);
        } else if (beam.dir == 'd' && beam.row < grid.length - 1) {
            new_beam = new Beam(beam.row + 1, beam.col, beam.dir);
        } else if (beam.dir == 'r' && beam.col < grid.length - 1) {
            new_beam = new Beam(beam.row, beam.col + 1, beam.dir);
        }

        auto exists = new_beam in energized;
        if (new_beam !is null && exists is null) {
            beams.insertBack(new_beam);
        }
    }

    while (!beams.empty()) {
        auto cur = beams.removeAny();
        auto action = grid[cur.row][cur.col];

        final switch (action) {
            case '.':
                add_next(cur);
                break;
            case '/':
                final switch (cur.dir) {
                    case 'u':
                        add_next(new Beam(cur.row, cur.col, 'r'));
                        break;
                    case 'l':
                        add_next(new Beam(cur.row, cur.col, 'd'));
                        break;
                    case 'd':
                        add_next(new Beam(cur.row, cur.col, 'l'));
                        break;
                    case 'r':
                        add_next(new Beam(cur.row, cur.col, 'u'));
                        break;
                }
                break;
            case '\\':
                final switch (cur.dir) {
                    case 'u':
                        add_next(new Beam(cur.row, cur.col, 'l'));
                        break;
                    case 'l':
                        add_next(new Beam(cur.row, cur.col, 'u'));
                        break;
                    case 'd':
                        add_next(new Beam(cur.row, cur.col, 'r'));
                        break;
                    case 'r':
                        add_next(new Beam(cur.row, cur.col, 'd'));
                        break;
                }
                break;
            case '-':
                if (cur.dir == 'l' || cur.dir == 'r') {
                    add_next(cur);
                } else {
                    add_next(new Beam(cur.row, cur.col, 'l'));
                    add_next(new Beam(cur.row, cur.col, 'r'));
                }
                break;
            case '|':
                if (cur.dir == 'u' || cur.dir == 'd') {
                    add_next(cur);
                } else {
                    add_next(new Beam(cur.row, cur.col, 'u'));
                    add_next(new Beam(cur.row, cur.col, 'd'));
                }
                break;
        }

        energized[cur] = true;
    }

    // Eliminate duplicates that only differ by direction
    bool[GridLoc] energized_pruned;
    foreach (b; energized.keys) {
        energized_pruned[new GridLoc(b.row, b.col)] = true;
    }

    return energized_pruned.length;
}

Beam get_next(string[] grid, Beam beam) {
    Beam new_beam = null;
    if (beam.dir == 'u' && beam.row > 0) {
        new_beam = new Beam(beam.row - 1, beam.col, beam.dir);
    } else if (beam.dir == 'l' && beam.col > 0) {
        new_beam = new Beam(beam.row, beam.col - 1, beam.dir);
    } else if (beam.dir == 'd' && beam.row < grid.length - 1) {
        new_beam = new Beam(beam.row + 1, beam.col, beam.dir);
    } else if (beam.dir == 'r' && beam.col < grid.length - 1) {
        new_beam = new Beam(beam.row, beam.col + 1, beam.dir);
    }

    return new_beam;
}

void get_full_path(string[] grid, Beam b, ref bool[Beam] path, ref bool[Beam][Beam] memo) {
    if (b is null) {
        writeln("Hit null!");
        return;
    }
    auto exists = b in path;
    if (exists) {
        writeln("Hit repeat!");
        return;
    }

    writef("Currently on: %s\n", b.toString());

    // Okay, do we have a path ready for this particular beam location?
    auto memo_exists = b in memo;
    if (memo_exists !is null) {
        auto memoized_path = memo[b];

        // We have the memo! We're good. No more recursion needed
        foreach (new_beam; memoized_path) {
            path[new_beam] = true;
        }
        return;
    }

    path[b] = true;

    auto action = grid[b.row][b.col];

    if (action == '.' ||
            (action == '-' && (b.dir == 'l' || b.dir == 'r')) ||
            (action == '|' && (b.dir == 'u' || b.dir == 'd'))) {
        get_full_path(grid, get_next(grid, b), path, memo);
    }
    if ((action == '/' && b.dir == 'r') ||
            (action == '\\' && b.dir == 'l') ||
            (action == '|' && (b.dir == 'l' || b.dir == 'r'))) {
        get_full_path(grid, get_next(grid, new Beam(b.row, b.col, 'u')), path, memo);
    }
    if ((action == '/' && b.dir == 'd') ||
            (action == '\\' && b.dir == 'u') ||
            (action == '-' && (b.dir == 'u' || b.dir == 'd'))) {
        get_full_path(grid, get_next(grid, new Beam(b.row, b.col, 'l')), path, memo);
    }
    if ((action == '/' && b.dir == 'l') ||
            (action == '\\' && b.dir == 'r') ||
            (action == '|' && (b.dir == 'l' || b.dir == 'r'))) {
        get_full_path(grid, get_next(grid, new Beam(b.row, b.col, 'd')), path, memo);
    }
    if ((action == '/' && b.dir == 'u') ||
            (action == '\\' && b.dir == 'd') ||
            (action == '-' && (b.dir == 'u' || b.dir == 'd'))) {
        get_full_path(grid, get_next(grid, new Beam(b.row, b.col, 'r')), path, memo);
    }

    // Memoize the path for this beam location
    memo[b] = path.dup();
}

// In order to evaluate the best starting point, we need memoize the beam path at every particular
// spot. Luckily the beam at each spot is deterministic, so at most we have 110 * 110 * 4 items in
// the map
ulong part2(string filename) {
    string[] grid = parse_grid(filename);

    // Memoize the path for every given Beam
    bool[Beam][Beam] memo;

    bool[Beam] energized;
    get_full_path(grid, new Beam(0, 0, 'r'), energized, memo);

    foreach(b; energized.keys) {
        writef("%s\n", b);
    }

    writef("AA count: %d\n", energized.length);

    return 0;
}

void main() {
    // writef("part1: %d\n", part1("day16.txt"));
    part2("sample16.txt");
}
