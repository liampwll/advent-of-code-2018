const std = @import("std");

const SIZE = 50;

pub fn main() void {
    lumber(@embedFile("input/18"));
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

fn lumber(input: []const u8) void {
    var area: [SIZE][SIZE]u8 = undefined;

    var line_it = std.mem.split(input, "\n");
    {var y: usize = 0; while (line_it.next()) |line| {
        for (line) |char, x| {
            area[y][x] = char;
        }
        y += 1;
    }}

    {var i: u32 = 0; while (i < 1000000000) : (i += 1) {
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
        std.debug.warn("{}, {}\n", i + 1, trees * yards);
    }}
}

// Output:
// ...
// 84794, 172898
// 84795, 169470 -----+
// 84796, 165780      |
// 84797, 169260      |
// 84798, 169524      |
// 84799, 168935      |
// 84800, 173952      |
// 84801, 179622      |
// 84802, 180299      |
// 84803, 188155      |
// 84804, 195776      |
// 84805, 192198      |
// 84806, 199076      |
// 84807, 206375      |
// 84808, 210576      | -- 28 lines apart
// 84809, 208658      |
// 84810, 212520      |
// 84811, 213395      |
// 84812, 216660      |
// 84813, 210368      |
// 84814, 203794      |
// 84815, 195510      |
// 84816, 180873      |
// 84817, 177126      |
// 84818, 176320      |
// 84819, 167862      |
// 84820, 169218      |
// 84821, 170428      |
// 84822, 172898      |
// 84823, 169470 -----+
// ...
//
// (1000000000 - 84795) % 28 = 9
// 84795 + 9 = 84804
// Line 84804 is 195776, therefore that's the answer
