const std = @import("std");

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try firstRepeat(&direct_allocator.allocator, @embedFile("input/1")));
}

fn firstRepeat(allocator: *std.mem.Allocator, input: []const u8) !i32 {
    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();

    var map = std.AutoHashMap(i32, void).init(allocator);
    defer map.deinit();

    var it = std.mem.split(input, "\n");

    while (it.next()) |line| {
        try list.append(try std.fmt.parseInt(i32, line, 10));
    }

    var sum: i32 = 0;
    outer: while (true) {
        for (list.toSlice()) |x| {
            if (map.contains(sum)) {
                break :outer;
            } else {
                _ = try map.put(sum, {});
            }
            sum += x;
        }
    }

    return sum;
}

test "samples" {
    std.debug.assert((try firstRepeat(std.debug.global_allocator, "+1\n-1\n")) == 0);
    std.debug.assert((try firstRepeat(std.debug.global_allocator, "+3\n+3\n+4\n-2\n-4\n")) == 10);
    std.debug.assert((try firstRepeat(std.debug.global_allocator, "-6\n+3\n+8\n+5\n-6\n")) == 5);
    std.debug.assert((try firstRepeat(std.debug.global_allocator, "+7\n+7\n-2\n-7\n-4\n")) == 14);
}
