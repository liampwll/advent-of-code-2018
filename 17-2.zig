const std = @import("std");

const TileType = enum {
    Water,
    Sand,
    Clay
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try water(@embedFile("input/17")));
}

fn water(input: []const u8) !usize {
    var line_it = std.mem.split(input, "\n");
    var table = [][2000]TileType{[]TileType{TileType.Sand} ** 2000} ** 2000;
    var min_y: usize = std.math.maxInt(usize);
    var max_y: usize = 0;
    while (line_it.next()) |line| {
        var nums_text = std.mem.split(line, "xy=, .");
        const nums = []usize{
            try std.fmt.parseInt(usize, nums_text.next().?, 10),
            try std.fmt.parseInt(usize, nums_text.next().?, 10),
            try std.fmt.parseInt(usize, nums_text.next().?, 10)
        };

        var i = std.math.min(nums[1], nums[2]);
        while (i <= std.math.max(nums[1], nums[2])) : (i += 1) {
            if (line[0] == 'y') {
                table[nums[0]][i] = TileType.Clay;
            } else {
                table[i][nums[0]] = TileType.Clay;
            }
        }

        if (line[0] == 'y') {
            min_y = std.math.min(min_y, nums[0]);
            max_y = std.math.max(max_y, nums[0]);
        } else {
            min_y = std.math.min(min_y, std.math.min(nums[1], nums[2]));
            max_y = std.math.max(max_y, std.math.max(nums[1], nums[2]));
        }
    }

    var res = down(table[0..(max_y + 1)], 0, 500);

    var i: u32 = 0;
    while (i < 10) : (i += 1) {
        for (table[0..(max_y + 1)]) |*line, y| {
            for (line) |*tile, x| {
                if (tile.* == TileType.Water and can_drain(table[0..(max_y + 1)], y, x)) {
                    tile.* = TileType.Sand;
                    res -= 1;
                }
            }
        }
    }

    for (table[0..(max_y + 2)]) |line| {
        for (line[420..580]) |x| {
            if (x == TileType.Sand) {
                std.debug.warn(".");
            } else if (x == TileType.Clay) {
                std.debug.warn("#");
            } else if (x == TileType.Water) {
                std.debug.warn("~");
            }
        }
        std.debug.warn("\n");
    }

    return res;
}

fn can_drain(table: [][2000]TileType, y: usize, x: usize) bool {
    var i = x;
    const can_go_left = while (true) : (i -= 1) {
        if (table[y][i] == TileType.Sand) {
            break true;
        }
        if (table[y][i] == TileType.Clay) {
            break false;
        }
    } else unreachable;

    var j = x;
    const can_go_right = while (true) : (j += 1) {
        if (table[y][j] == TileType.Sand) {
            break true;
        }
        if (table[y][j] == TileType.Clay) {
            break false;
        }
    } else unreachable;

    return can_go_left or can_go_right;
}

fn down(table: [][2000]TileType, y: usize, x: usize) usize {
    if (y == table.len) {
        return 0;
    }

    switch (table[y][x]) {
        TileType.Sand => {
            table[y][x] = TileType.Water;
            return 1 + down(table, y + 1, x) + left(table, y, x) + right(table, y, x);
        },
        TileType.Clay => {
            return 0;
        },
        TileType.Water => {
            return 0;
        }
    }
}

fn can_spread(table: [][2000]TileType, y: usize, x: usize) bool {
    if (y + 1 == table.len) {
        return false;
    }

    var i = x;
    const can_go_left = while (i != 0) : (i -= 1) {
        if (table[y + 1][i] == TileType.Sand) {
            break false;
        }
        if (table[y + 1][i] == TileType.Clay) {
            break true;
        }
    } else blk: {
        break :blk false;
    };

    var j = x;
    const can_go_right = while (j != table.len - 1) : (j += 1) {
        if (table[y + 1][j] == TileType.Sand) {
            break false;
        }
        if (table[y + 1][j] == TileType.Clay) {
            break true;
        }
    } else blk: {
        break :blk false;
    };

    return can_go_left and can_go_right;
}

fn left(table: [][2000]TileType, y: usize, x: usize) usize {
    if (!can_spread(table, y, x)) {
        return 0;
    }

    var i = x - 1;
    while (table[y + 1][i] != TileType.Sand and table[y][i] == TileType.Sand) : (i -= 1) {
        table[y][i] = TileType.Water;
    }

    if (table[y][i] == TileType.Sand) {
        return down(table, y, i) + ((x - 1) - i);
    } else {
        return (x - 1) - i;
    }
}

fn right(table: [][2000]TileType, y: usize, x: usize) usize {
    if (!can_spread(table, y, x)) {
        return 0;
    }

    var i = x + 1;
    while (table[y + 1][i] != TileType.Sand and table[y][i] == TileType.Sand) : (i += 1) {
        table[y][i] = TileType.Water;
    }

    if (table[y][i] == TileType.Sand) {
        return down(table, y, i) + (i - (x + 1));
    } else {
        return i - (x + 1);
    }
}
