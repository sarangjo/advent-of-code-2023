import std.stdio;
import std.exception;
import std.container : DList;
import std.typecons;

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

        // writef("cur %d,%d; dir %c; action %c\n", cur.row, cur.col, cur.dir, action);

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

void main() {
    writef("part1: %d\n", part1("day16.txt"));
}
