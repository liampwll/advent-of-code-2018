const std = @import("std");
const io = std.io;
const fmt = std.fmt;

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var list = std.ArrayList(i32).init(&direct_allocator.allocator);
    defer list.deinit();

    var map = std.AutoHashMap(i32, void).init(&direct_allocator.allocator);
    defer map.deinit();

    var line_buf: [20]u8 = undefined;
    while (io.readLine(line_buf[0..])) |line_len| {
        const x = try fmt.parseInt(i32, line_buf[0..line_len], 10);
        try list.append(x);
    } else |err| {
    }

    var sum: i32 = 0;
    outer: while (true) {
        for (list.toSlice()) |x| {
            sum += x;
            if (map.contains(sum)) {
                break :outer;
            } else {
                _ = try map.put(sum, {});
            }
        }
    }

    std.debug.warn("{}", sum);
}
