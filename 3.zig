const std = @import("std");
const io = std.io;
const fmt = std.fmt;

pub fn main() !void {
    var overlap: u32 = 0;
    var fabric = [][2000]u8{[]u8{0} ** 2000} ** 2000;

    var line_buf: [50]u8 = undefined;
    while (io.readLine(line_buf[0..])) |line_len| {
        var iter = std.mem.split(line_buf[0..line_len], "# @,:x");
        const id = try fmt.parseInt(u32, iter.next().?, 10);
        const start_x = try fmt.parseInt(u32, iter.next().?, 10);
        const start_y = try fmt.parseInt(u32, iter.next().?, 10);
        const size_x = try fmt.parseInt(u32, iter.next().?, 10);
        const size_y = try fmt.parseInt(u32, iter.next().?, 10);
        var y = start_y;
        while (y < start_y + size_y) : (y += 1) {
            var x = start_x;
            while (x < start_x + size_x) : (x += 1) {
                if (fabric[y][x] == 1) {
                    overlap += 1;
                }
                fabric[y][x] += 1;
            }
        }
    } else |err| {
    }

    std.debug.warn("{}\n", overlap);
}
