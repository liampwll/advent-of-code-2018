const std = @import("std");

const SIZE = 50;

pub fn main() void {
    std.debug.warn("{}\n", lumber(@embedFile("input/18")));
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

fn lumber(input: []const u8) u32 {
    var area: [SIZE][SIZE]u8 = undefined;

    var line_it = std.mem.split(input, "\n");
    {var y: usize = 0; while (line_it.next()) |line| {
        for (line) |char, x| {
            area[y][x] = char;
        }
        y += 1;
    }}

    {var i: u32 = 0; while (i < 10) : (i += 1) {
        const area_copy = area;
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
    }}

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
