const std = @import("std");

const Step = struct {
    done: bool,
    deps: std.ArrayList(u8)
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try solve(&direct_allocator.allocator, @embedFile("input/7")));
}

fn solve(allocator: *std.mem.Allocator, input: []const u8) ![26]u8 {
    var steps: [26]Step = undefined;

    for (steps) |*x| {
        x.done = false;
        x.deps = std.ArrayList(u8).init(allocator);
    }

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        try steps[line[36] - 'A'].deps.append(line[5] - 'A');
    }

    var result: [26]u8 = undefined;
    var i: u8 = 0;
    while (i < 26) : (i += 1) {
        const next = outer: for (steps) |x, x_i| {
            if (x.done) {
                continue;
            }
            for (x.deps.toSlice()) |dep| {
                if (!steps[dep].done) {
                    continue :outer;
                }
            }
            break x_i;
        } else {
            unreachable;
        };
        result[i] = @intCast(u8, next + 'A');
        steps[next].done = true;
    }

    return result;
}
