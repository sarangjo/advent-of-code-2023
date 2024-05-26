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

// Eliminate duplicates that only differ by direction
ulong get_true_energized_count(bool[Beam] energized) {
    bool[GridLoc] energized_pruned;
    foreach (b; energized.keys) {
        energized_pruned[new GridLoc(b.row, b.col)] = true;
    }

    return energized_pruned.length;
}

ulong part1(string filename) {
    string[] grid = parse_grid(filename);
    bool[Beam] energized;

    get_full_path_iter(grid, new Beam(0, 0, 'r'), energized);

    return get_true_energized_count(energized);
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

void get_full_path_iter(string[] grid, Beam start, ref bool[Beam] energized) {
    auto beams = DList!Beam(start);

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
}

ulong part2(string filename) {
    string[] grid = parse_grid(filename);

    ulong best = 0;

    // Go through all of the grid entries
    Beam[] starts = new Beam[grid.length * 4];
    // top
    for (int i = 0; i < grid.length; i++) {
        starts[i] = new Beam(0, i, 'd');
    }
    // right
    for (int i = 0; i < grid.length; i++) {
        starts[grid.length + i] = new Beam(i, cast(int) grid.length - 1, 'l');
    }
    // bot
    for (int i = 0; i < grid.length; i++) {
        starts[grid.length * 2 + i] = new Beam(cast(int) grid.length - 1, i, 'u');
    }
    // left
    for (int i = 0; i < grid.length; i++) {
        starts[grid.length * 3 + i] = new Beam(i, 0, 'r');
    }

    foreach (start; starts) {
        bool[Beam] energized;
        get_full_path_iter(grid, start, energized);

        ulong true_count = get_true_energized_count(energized);
        if (true_count > best) {
            best = true_count;
        }
    }

    return best;
}

void main() {
    writef("part1: %d\n", part1("day16.txt"));
    writef("part2: %d\n", part2("day16.txt"));
}
