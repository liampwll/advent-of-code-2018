const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const math = std.math;

fn mDist(a: [2]i32, b: [2]i32) i32 {
    return (math.absInt(a[0] - b[0]) catch unreachable)
        + (math.absInt(a[1] - b[1]) catch unreachable);
}

const MAX_X = 500;
const MAX_Y = 500;

pub fn main() !void {
    var largest: i32 = 0;

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

    outer: for (points.toSlice()) |*p| {
        var area: i32 = 0;
        var y: i32 = 0;
        while (y <= MAX_Y) : (y += 1) {
            var x: i32 = 0;
            while (x <= MAX_X) : (x += 1) {
                var closest = true;
                for (points.toSlice()) |*p2| {
                    if (p2 != p and mDist(p2.*, []i32{x, y}) <= mDist(p.*, []i32{x, y})) {
                        closest = false;
                        break;
                    }
                }
                if (closest) {
                    if (x == 0 or y == 0 or x == MAX_X or y == MAX_Y) {
                        continue :outer;
                    }
                    area += 1;
                }
            }
        }
        if (area > largest) {
            largest = area;
        }
    }

    std.debug.warn("{}\n", largest);
}
