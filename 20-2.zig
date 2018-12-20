// This doesn't work and I have no idea why.

const std = @import("std");

const SIZE = 120;
const START = SIZE / 2;

const Room = struct {
    west: bool,
    north: bool,
    last_here: usize,
    depth: usize
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var rooms = try direct_allocator.allocator.alloc([SIZE]Room, SIZE);
    for (rooms) |*line| {
        for (line) |*room| {
            room.* = Room{.west = false, .north = false, .last_here = std.math.maxInt(usize), .depth = 0};
        }
    }

    path(@embedFile("input/20"), 0, rooms, START, START);
    _ = try bfs(&direct_allocator.allocator, rooms, START, START);

    var n: usize = 0;
    for (rooms) |line| {
        for (line) |room| {
            if (room.depth >= 1000) {
                n += 1;
            }
        }
    }

    std.debug.warn("{}\n", n);
}

fn path(input: []const u8, pos_: usize, rooms: [][SIZE]Room, y_: usize, x_: usize) void {
    var y = y_;
    var x = x_;
    var pos: usize = pos_;
    while (pos < input.len) : (pos += 1) {
        if (rooms[y][x].last_here == pos) {
            return;
        } else {
            rooms[y][x].last_here = pos;
        }

        switch (input[pos]) {
            'N' => {
                rooms[y][x].north = true;
                y -= 1;
            },
            'W' => {
                rooms[y][x].west = true;
                x -= 1;
            },
            'E' => {
                x += 1;
                rooms[y][x].west = true;
            },
            'S' => {
                y += 1;
                rooms[y][x].north = true;
            },
            '|' => {
                var depth: usize = 1;
                while (depth != 0) {
                    pos += 1;
                    if (input[pos] == '(') {
                        depth += 1;
                    } else if (input[pos] == ')') {
                        depth -= 1;
                    }
                }
            },
            '(' => {
                path(input, pos + 1, rooms, y, x);

                var depth: usize = 0;
                while (depth != 0 or input[pos] != '|') {
                    pos += 1;
                    if (input[pos] == '(') {
                        depth += 1;
                    } else if (input[pos] == ')') {
                        depth -= 1;
                    }
                }

                path(input, pos + 1, rooms, y, x);

                return;
            },
            else => {}
        }
    }
}

fn bfs(allocator: *std.mem.Allocator, rooms: [][SIZE]Room, y: usize, x: usize) !usize {
    var visited = try allocator.alloc([SIZE]bool, SIZE);
    for (visited) |*line| {
        for (line) |*room| {
            room.* = false;
        }
    }
    visited[y][x] = true;

    var next = std.ArrayList([2]usize).init(allocator);
    try next.append([]usize{y, x});

    return bfsReal(allocator, &next, rooms, visited, 0);
}

fn bfsReal(allocator: *std.mem.Allocator,
           next: *std.ArrayList([2]usize),
           rooms: [][SIZE]Room,
           visited: [][SIZE]bool,
           depth: usize) error{
    OutOfMemory
}!usize {
    var next_next = std.ArrayList([2]usize).init(allocator);

    for (next.toSliceConst()) |p| {
        rooms[p[0]][p[1]].depth = depth;

        if (!visited[p[0] - 1][p[1]] and rooms[p[0]][p[1]].north) {
            visited[p[0] - 1][p[1]] = true;
            try next_next.append([]usize{p[0] - 1, p[1]});
        }
        if (!visited[p[0]][p[1] - 1] and rooms[p[0]][p[1]].west) {
            visited[p[0]][p[1] - 1] = true;
            try next_next.append([]usize{p[0], p[1] - 1});
        }
        if (!visited[p[0] + 1][p[1]] and rooms[p[0] + 1][p[1]].north) {
            visited[p[0] + 1][p[1]] = true;
            try next_next.append([]usize{p[0] + 1, p[1]});
        }
        if (!visited[p[0]][p[1] + 1] and rooms[p[0]][p[1] + 1].west) {
            visited[p[0]][p[1] + 1] = true;
            try next_next.append([]usize{p[0], p[1] + 1});
        }
    }

    next.deinit();

    if (next_next.count() != 0) {
        return bfsReal(allocator, &next_next, rooms, visited, depth + 1);
    } else {
        next_next.deinit();
        return depth;
    }
}
