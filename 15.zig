const std = @import("std");

const UnitKind = enum {
    Goblin,
    Elf
};

const Unit = struct {
    last_turn: u32,
    kind: UnitKind,
    health: u32
};

const Tile = struct {
    unit: ?Unit,
    isWall: bool
};

const BfsResult = struct {
    start: Point,
    end: Point,
    depth: usize
};

const Side = enum(u8) {
    Top,
    Left,
    Right,
    Bottom,

    fn addToPoint(self: Side, p: Point) Point {
        return switch (self) {
            Side.Top => Point{.y = p.y - 1, .x = p.x},
            Side.Bottom => Point{.y = p.y + 1, .x = p.x},
            Side.Left => Point{.y = p.y, .x = p.x - 1},
            Side.Right => Point{.y = p.y, .x = p.x + 1}
        };
    }
};

const SideArray = []Side{Side.Top, Side.Left, Side.Right, Side.Bottom};

const Point = struct {
    y: usize,
    x: usize
};

const GRID_SIZE = 32;
const START_HEALTH = 200;
const ATTACK = 3;

pub fn main() void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", battle(&direct_allocator.allocator, @embedFile("input/15")));
}

fn battle(allocator: *std.mem.Allocator, input: []const u8) u32 {
    var grid: [GRID_SIZE][GRID_SIZE]Tile = undefined;
    var goblins: u32 = 0;
    var elves: u32 = 0;
    var line_it = std.mem.split(input, "\n");
    {var y: usize = 0; while (line_it.next()) |line| {
        for (line) |char, x| {
            grid[y][x] = switch (char) {
                '#' => Tile{.isWall = true, .unit = null},
                '.' => Tile{.isWall = false, .unit = null},
                'E' => blk: {
                    elves += 1;
                    break :blk Tile{
                        .isWall = false,
                        .unit = Unit{
                            .last_turn = 0,
                            .kind = UnitKind.Elf,
                            .health = START_HEALTH
                        }
                    };
                },
                'G' => blk: {
                    goblins += 1;
                    break :blk Tile{
                        .isWall = false,
                        .unit = Unit{
                            .last_turn = 0,
                            .kind = UnitKind.Goblin,
                            .health = START_HEALTH
                        }
                    };
                },
                else => unreachable
            };
        }
        y += 1;
    }}

    var turn: u32 = 1;
    outer: while (elves != 0 and goblins != 0) : (turn += 1) {
        for (grid) |*line, y| {
            for (line) |*tile, x| {
                if (tile.unit != null and tile.unit.?.last_turn != turn) {
                    if (elves == 0 or goblins == 0) {
                        break :outer;
                    }

                    var unit = tile.unit.?;
                    var p = Point{.y = y, .x = x};

                    if (bfs(allocator, &grid, p)) |move| {
                        p = move.start;
                        unit.last_turn = turn;
                        grid[p.y][p.x].unit = unit;
                        tile.unit = null;
                    }

                    if (select_target(&grid, p, unit.kind)) |t| {
                        const t_unit = &grid[t.y][t.x].unit.?;
                        if (t_unit.health <= ATTACK) {
                            switch (t_unit.kind) {
                                UnitKind.Elf => {elves -= 1;},
                                UnitKind.Goblin => {goblins -= 1;}
                            }
                            grid[t.y][t.x].unit = null;
                        } else {
                            t_unit.health -= ATTACK;
                        }
                    }
                }
            }
        }
        std.debug.warn("\n{}\n", turn);
        print_grid(&grid);
    }

    var health: u32 = 0;
    for (grid) |line, y| {
        for (line) |tile, x| {
            if (tile.unit) |unit| {
                health += unit.health;
            }
        }
    }

    std.debug.warn("{}, {}\n", turn - 1, health);
    return (turn - 1) * health;
}

fn print_grid(grid: *const [GRID_SIZE][GRID_SIZE]Tile) void {
    for (grid) |line, y| {
        for (line) |tile, x| {
            if (tile.unit) |unit| {
                switch (unit.kind) {
                    UnitKind.Elf => {std.debug.warn("E");},
                    UnitKind.Goblin => {std.debug.warn("G");}
                }
            } else if (tile.isWall) {
                std.debug.warn("#");
            } else {
                std.debug.warn(".");
            }
        }
        std.debug.warn("   ");
        for (line) |tile, x| {
            if (tile.unit) |unit| {
                switch (unit.kind) {
                    UnitKind.Elf => {std.debug.warn("E({}), ", unit.health);},
                    UnitKind.Goblin => {std.debug.warn("G({}), ", unit.health);}
                }
            }
        }
        std.debug.warn("\n");
    }
}

fn select_target(grid: *const [GRID_SIZE][GRID_SIZE]Tile, p: Point, kind: UnitKind) ?Point {
    var target: ?Point = null;
    var target_health: u32 = std.math.maxInt(u32);
    for (SideArray) |side| {
        const p2 = side.addToPoint(p);
        if (grid[p2.y][p2.x].unit) |other| {
            if (other.kind != kind and other.health < target_health) {
                target_health = other.health;
                target = p2;
            }
        }
    }

    return target;
}

fn bfs(allocator: *std.mem.Allocator, grid: *const [GRID_SIZE][GRID_SIZE]Tile, start: Point) ?BfsResult {
    if (select_target(grid, start, grid[start.y][start.x].unit.?.kind)) |_| {
        return null;
    }

    var visited = [][GRID_SIZE][4]bool{[][4]bool{[]bool{false} ** 4} ** GRID_SIZE} ** GRID_SIZE;
    for (visited) |*line, y| {
        for (line) |*tile, x| {
            if (grid[y][x].isWall or grid[y][x].unit != null) {
                tile.* = []bool{true} ** 4;
            }
        }
    }
    var next = std.ArrayList(BfsResult).init(allocator);
    const start2 = BfsResult{
        .start = start,
        .end = start,
        .depth = 0
    };
    bfs_append_next(start2, &next, grid, &visited);
    for (next.toSlice()) |*x| {
        x.start = x.end;
    }
    return bfs_real(allocator, &next, grid, &visited, grid[start.y][start.x].unit.?.kind);
}

fn bfs_real(allocator: *std.mem.Allocator,
            next: *std.ArrayList(BfsResult),
            grid: *const [GRID_SIZE][GRID_SIZE]Tile,
            visited: *[GRID_SIZE][GRID_SIZE][4]bool,
            kind: UnitKind) ?BfsResult {
    var next_next = std.ArrayList(BfsResult).init(allocator);
    var ends = std.ArrayList(BfsResult).init(allocator);
    defer ends.deinit();

    for (next.toSliceConst()) |x| {
        if (select_target(grid, x.end, kind)) |_| {
            ends.append(x) catch unreachable;
        } else {
            bfs_append_next(x, &next_next, grid, visited);
        }
    }

    next.deinit();

    if (ends.count() != 0) {
        next_next.deinit();
        std.sort.sort(BfsResult, ends.toSlice(), bfs_result_comparator);
        for (ends.toSliceConst()) |x| {
            // std.debug.warn("{}\n", x);
        }
        // std.debug.warn("\n");
        return ends.at(0);
    } else if (next_next.count() == 0) {
        next_next.deinit();
        return null;
    } else {
        return bfs_real(allocator, &next_next, grid, visited, kind);
    }
}

fn bfs_result_comparator(a: BfsResult, b: BfsResult) bool {
    return lexical([]usize{a.end.y, a.end.x, a.start.y, a.start.x},
                   []usize{b.end.y, b.end.x, b.start.y, b.start.x});
}

fn lexical(a: []const usize, b: []const usize) bool {
    var i: usize = 0;
    while (i < a.len and a[i] == b[i]) : (i += 1) {
    }
    if (i == a.len) {
        return true;
    } else {
        return a[i] < b[i];
    }
}

fn bfs_append_next(x: BfsResult,
                   next: *std.ArrayList(BfsResult),
                   grid: *const [GRID_SIZE][GRID_SIZE]Tile,
                   visited: *[GRID_SIZE][GRID_SIZE][4]bool) void {
    for (SideArray) |side| {
        const p = side.addToPoint(x.end);
        if (!visited[p.y][p.x][@intCast(usize, @enumToInt(side))]) {
            next.append(BfsResult{
                .start = x.start,
                .end = p,
                .depth = x.depth + 1
            }) catch unreachable;
            visited[p.y][p.x][@intCast(usize, @enumToInt(side))] = true;
        }
    }
}
