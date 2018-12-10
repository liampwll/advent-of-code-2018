const std = @import("std");

const Point = struct {
    x: i32,
    y: i32,
    dx: i32,
    dy: i32
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    try something(&direct_allocator.allocator, @embedFile("input/10"));
}

fn something(allocator: *std.mem.Allocator, input: []const u8) !void {
    var points = std.ArrayList(Point).init(allocator);

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        var it = std.mem.split(line, "position=<, > velocity=<, >");
        try points.append(Point{
            .x = try std.fmt.parseInt(i32, it.next().?, 10),
            .y = try std.fmt.parseInt(i32, it.next().?, 10),
            .dx = try std.fmt.parseInt(i32, it.next().?, 10),
            .dy = try std.fmt.parseInt(i32, it.next().?, 10)
        });
    }

    var t: i32 = 0;
    while (true) : (t += 1) {
        var min_x: i32 = 2000000000;
        var max_x: i32 = -2000000000;
        var min_y: i32 = 2000000000;
        var max_y: i32 = -2000000000;
        for (points.toSliceConst()) |p| {
            if (p.x + p.dx * t < min_x) {min_x = p.x + p.dx * t;}
            if (p.x + p.dx * t > max_x) {max_x = p.x + p.dx * t;}
            if (p.y + p.dy * t < min_y) {min_y = p.y + p.dy * t;}
            if (p.y + p.dy * t > max_y) {max_y = p.y + p.dy * t;}
        }
        if (max_x - min_x < 200 and max_y - min_y < 15) {
            std.debug.warn("\x1B[2J");
            for (points.toSliceConst()) |p| {
                std.debug.warn("\x1B[{};{}H#", p.y + p.dy * t - min_y + 1, p.x + p.dx * t - min_x + 1);
            }
            std.debug.warn("\x1B[{};1H", max_y - min_y + 5);
            std.debug.warn("{}", t);
            return;
        }
    }
}
