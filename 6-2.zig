const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const math = std.math;

fn mDist(a: [2]i32, b: [2]i32) i32 {
    return (math.absInt(a[0] - b[0]) catch unreachable)
        + (math.absInt(a[1] - b[1]) catch unreachable);
}

const SAFE = 10000;

pub fn main() !void {
    var area: i32 = 0;

    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var points = std.ArrayList([2]i32).init(&direct_allocator.allocator);
    defer points.deinit();

    var line_buf: [50]u8 = undefined;
    while (io.readLine(line_buf[0..])) |len| {
        var iter = std.mem.split(line_buf[0..len], ", ");
        const x = try fmt.parseInt(i32, iter.next().?, 10);
        const y = try fmt.parseInt(i32, iter.next().?, 10);
        _ = try points.append([]i32{x, y});
    } else |err| {
    }

    var y: i32 = -SAFE;
    while (y <= SAFE) : (y += 1) {
        var x: i32 = -SAFE;
        while (x <= SAFE) : (x += 1) {
            var sum: i32 = 0;
            for (points.toSlice()) |*p| {
                sum += mDist(p.*, []i32{x, y});
            }

            if (sum < SAFE) {
                area += 1;
            }
        }
    }

    std.debug.warn("{}\n", area);
}
