const std = @import("std");

const max_x = 500;
const max_y = 500;

const Point = struct {
    x: u32,
    y: u32,
    area: u32,
    infinite: bool
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try findLargest(&direct_allocator.allocator, @embedFile("input/6")));
}

fn mDist(a: Point, b: Point) !u32 {
    return @intCast(u32, (try std.math.absInt(@intCast(i64, a.x) - @intCast(i64, b.x))))
        + @intCast(u32, (try std.math.absInt(@intCast(i64, a.y) - @intCast(i64, b.y))));
}

fn findLargest(allocator: *std.mem.Allocator, input: []const u8) !u32 {
    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        var num_it = std.mem.split(line, ", ");
        const x = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const y = try std.fmt.parseInt(u32, num_it.next().?, 10);
        _ = try points.append(Point{.x = x, .y = y, .area = 0, .infinite = false});
    }

    var y: u32 = 0;
    while (y <= max_y) : (y += 1) {
        var x: u32 = 0;
        while (x <= max_x) : (x += 1) {
            const p = Point{.x = x, .y = y, .area = 0, .infinite = false};
            if (try closestPoint(p, points.toSlice())) |closest| {
                if (x == 0 or y == 0 or x == max_x or y == max_y) {
                    closest.infinite = true;
                }
                closest.area += 1;
            }
        }
    }

    var largest: u32 = 0;
    for (points.toSliceConst()) |p| {
        if (!p.infinite and p.area > largest) {
            largest = p.area;
        }
    }

    return largest;
}

fn closestPoint(point: Point, others: []Point) !?*Point {
    var closest = &others[0];
    var closest_dist: u32 = try mDist(point, closest.*);
    var conflict = false;

    for (others[1..]) |*p| {
        const dist = try mDist(point, p.*);
        if (dist == closest_dist) {
            conflict = true;
        } if (dist < closest_dist) {
            closest = p;
            closest_dist = dist;
            conflict = false;
        }
    }

    return if (conflict) null else closest;
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
    std.debug.assert((try findLargest(std.debug.global_allocator, input)) == 17);
}
