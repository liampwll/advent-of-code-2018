const std = @import("std");

pub fn main() void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    plants(@embedFile("input/12"));
}

fn plants(input: []const u8) void {
    var last = []bool{false} ** (1000 * 2 + 100);
    var current = []bool{false} ** (1000 * 2 + 100);
    var states = []bool{false} ** 32; // 2 ** 5

    var line_it = std.mem.split(input, "\n");

    for (line_it.next().?[15..]) |x, i| {
        if (x == '#') {
            current[i + 1000] = true;
        }
    }

    while (line_it.next()) |line| {
        var index: usize = 0;
        for (line[0..5]) |x| {
            index <<= 1;
            if (x == '#') {
                index |= 1;
            }
        }
        states[index] = line[9] == '#';
    }

    var last_sum: i64 = 0;

    {var i: u32 = 0; while (i < 1000) : (i += 1) {
        last = current;

        {var j: usize = 2; while (j < last.len - 2) : (j += 1) {
            var index: usize = 0;
            for (last[(j - 2)..(j + 3)]) |x| {
                index <<= 1;
                if (x) {
                    index |= 1;
                }
            }
            current[j] = states[index];
        }}

        var sum: i64 = 0;
        for (current) |x, j| {
            if (x) {
                sum += @intCast(i64, j) - 1000;
            }
        }
        std.debug.warn("{}: {}, {}\n", i, sum, sum - last_sum);
        last_sum = sum;
    }}
}
