const std = @import("std");

const Step = struct {
    done: bool,
    working: bool,
    time_left: u32,
    deps: std.ArrayList(u8)
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try solve(&direct_allocator.allocator, @embedFile("input/7")));
}

fn solve(allocator: *std.mem.Allocator, input: []const u8) !u32 {
    var steps: [26]Step = undefined;

    for (steps) |*x, i| {
        x.done = false;
        x.working = false;
        x.time_left = 61 + @intCast(u32, i);
        x.deps = std.ArrayList(u8).init(allocator);
    }

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        try steps[line[36] - 'A'].deps.append(line[5] - 'A');
    }

    var i: u8 = 0;
    var time: u32 = 0;
    var free_workers: u32 = 5;
    while (i < 26) : (time += 1) {
        for (steps) |*x, x_i| {
            if (!x.done and !x.working) {
                const all_deps_done = for (x.deps.toSlice()) |dep| {
                    if (!steps[dep].done) {
                        break false;
                    }
                } else blk: {
                    break :blk true;
                };

                if (all_deps_done and free_workers != 0) {
                    free_workers -= 1;
                    x.working = true;
                }
            }
        }

        for (steps) |*x, x_i| {
            if (x.working) {
                x.time_left -= 1;
                if (x.time_left == 0) {
                    x.done = true;
                    x.working = false;
                    free_workers += 1;
                    i += 1;
                }
            }
        }
    }

    return time;
}
