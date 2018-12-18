const std = @import("std");

const SIZE = 50;
const STEPS = 1000000000;

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try lumber(&direct_allocator.allocator, @embedFile("input/18")));
}

fn lumber(allocator: *std.mem.Allocator, input: []const u8) !u32 {
    var area: [SIZE][SIZE]u8 = undefined;
    var seen = std.hash_map.HashMap([SIZE][SIZE]u8, u32, fnv1a32, arrayEql).init(allocator);

    var line_it = std.mem.split(input, "\n");
    {var y: usize = 0; while (line_it.next()) |line| {
        for (line) |char, x| {
            area[y][x] = char;
        }
        y += 1;
    }}


    var i: u32 = 0;
    const prev = while (i < STEPS) : (i += 1) {
        const gop = try seen.getOrPut(area);
        if (gop.found_existing) {
            break gop.kv.value;
        } else {
            gop.kv.value = i;
        }

        step(&area);
    } else unreachable;

    const steps_left = (STEPS - i) % (i - prev);

    var j: u32 = 0;
    while (j < steps_left) : (j += 1) {
        step(&area);
    }

    var trees: u32 = 0;
    var yards: u32 = 0;
    for (area) |line| {
        for (line) |char| {
            if (char == '|') {
                trees += 1;
            } else if (char == '#') {
                yards += 1;
            }
        }
    }

    return trees * yards;
}

fn step(area: *[SIZE][SIZE]u8) void {
    const area_copy = area.*;
    for (area_copy) |line, y| {
        for (line) |char, x| {
            if (char == '.') {
                if (countAdjacent(area_copy, y, x, '|') >= 3) {
                    area[y][x] = '|';
                }
            } else if (char == '|') {
                if (countAdjacent(area_copy, y, x, '#') >= 3) {
                    area[y][x] = '#';
                }
            } else if (char == '#') {
                if (countAdjacent(area_copy, y, x, '#') == 0
                        or countAdjacent(area_copy, y, x, '|') == 0) {
                    area[y][x] = '.';
                }
            }
        }
    }
}

fn countAdjacent(area: [SIZE][SIZE]u8, y: usize, x: usize, char: u8) u32 {
    var count: u32 = 0;

    if (y > 0 and area[y - 1][x] == char) {
        count += 1;
    }
    if (y < area.len - 1 and area[y + 1][x] == char) {
        count += 1;
    }
    if (x > 0 and area[y][x - 1] == char) {
        count += 1;
    }
    if (x < area[0].len - 1 and area[y][x + 1] == char) {
        count += 1;
    }

    if (y > 0 and x > 0 and area[y - 1][x - 1] == char) {
        count += 1;
    }
    if (y < area.len - 1 and x < area.len - 1 and area[y + 1][x + 1] == char) {
        count += 1;
    }
    if (y > 0 and x < area.len - 1 and area[y - 1][x + 1] == char) {
        count += 1;
    }
    if (y < area.len - 1 and x > 0 and area[y + 1][x - 1] == char) {
        count += 1;
    }

    return count;
}

fn arrayEql(key_a: [SIZE][SIZE]u8, key_b: [SIZE][SIZE]u8) bool {
    for (key_a) |line, y| {
        for (line) |char, x| {
            if (key_b[y][x] != char) {
                return false;
            }
        }
    }
    return true;
}

fn fnv1a32(key: [SIZE][SIZE]u8) u32 {
    var res: u32 = 2166136261;
    for (key) |line| {
        for (line) |char| {
            res = (res ^ @intCast(u32, char)) *% 16777619;
        }
    }
    return res;
}
