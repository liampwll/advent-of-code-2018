const std = @import("std");

const max_x = 10000;
const max_y = 10000;
const safe = 10000;

const Point = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try countSafe(&direct_allocator.allocator, @embedFile("input/6")));
}

fn mDist(a: Point, b: Point) !u32 {
    return @intCast(u32, (try std.math.absInt(@intCast(i64, a.x) - @intCast(i64, b.x))))
        + @intCast(u32, (try std.math.absInt(@intCast(i64, a.y) - @intCast(i64, b.y))));
}

fn countSafe(allocator: *std.mem.Allocator, input: []const u8) !u32 {
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
    var y: i32 = -max_y;
    while (y <= max_y) : (y += 1) {
        var x: i32 = -max_x;
        while (x <= max_x) : (x += 1) {
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
    std.debug.assert((try countSafe(std.debug.global_allocator, input)) == 16);
}
