const std = @import("std");

const Point = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try countSafe(&direct_allocator.allocator, @embedFile("input/6"), 10000));
}

fn mDist(a: Point, b: Point) !u32 {
    return @intCast(u32, (try std.math.absInt(@intCast(i64, a.x) - @intCast(i64, b.x))))
        + @intCast(u32, (try std.math.absInt(@intCast(i64, a.y) - @intCast(i64, b.y))));
}

fn countSafe(allocator: *std.mem.Allocator, input: []const u8, safe: u32) !u32 {
    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        var num_it = std.mem.split(line, ", ");
        const x = try std.fmt.parseInt(i32, num_it.next().?, 10);
        const y = try std.fmt.parseInt(i32, num_it.next().?, 10);
        _ = try points.append(Point{.x = x, .y = y});
    }

    var area: u32 = 0;
    var y: i32 = -@intCast(i32, safe);
    while (y <= @intCast(i32, safe)) : (y += 1) {
        var x: i32 = -@intCast(i32, safe);
        while (x <= @intCast(i32, safe)) : (x += 1) {
            const p = Point{.x = x, .y = y};
            var sum: u32 = 0;
            for (points.toSliceConst()) |p2| {
                sum += try mDist(p, p2);
            }
            if (sum < safe) {
                area += 1;
            }
        }
    }

    return area;
}

test "samples" {
    const input =
        \\1, 1
        \\1, 6
        \\8, 3
        \\3, 4
        \\5, 5
        \\8, 9
    ;
    std.debug.assert((try countSafe(std.debug.global_allocator, input, 32)) == 16);
}
