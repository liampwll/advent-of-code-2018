const std = @import("std");
const io = std.io;
const fmt = std.fmt;

pub fn main() !void {
    var fabric = [][2000]u16{[]u16{0} ** 2000} ** 2000;
    var valid_claims = []bool{false} ** 2000;

    var line_buf: [50]u8 = undefined;
    while (io.readLine(line_buf[0..])) |line_len| {
        var iter = std.mem.split(line_buf[0..line_len], "# @,:x");
        const id = try fmt.parseInt(u16, iter.next().?, 10);
        const start_x = try fmt.parseInt(u32, iter.next().?, 10);
        const start_y = try fmt.parseInt(u32, iter.next().?, 10);
        const size_x = try fmt.parseInt(u32, iter.next().?, 10);
        const size_y = try fmt.parseInt(u32, iter.next().?, 10);
        valid_claims[id] = true;
        var y = start_y;
        while (y < start_y + size_y) : (y += 1) {
            var x = start_x;
            while (x < start_x + size_x) : (x += 1) {
                if (fabric[y][x] != 0) {
                    valid_claims[fabric[y][x]] = false;
                    valid_claims[id] = false;
                }
                fabric[y][x] = id;
            }
        }
    } else |err| {
    }

    for (valid_claims) |is_valid, id| {
        if (is_valid) {
            std.debug.warn("{}\n", id);
        }
    }
}
