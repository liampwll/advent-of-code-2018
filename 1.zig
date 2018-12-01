const std = @import("std");
const io = std.io;
const fmt = std.fmt;

pub fn main() !void {
    var sum: i32 = 0;

    var line_buf: [20]u8 = undefined;
    while (io.readLine(line_buf[0..])) |line_len| {
        const x = try fmt.parseInt(i32, line_buf[0..line_len], 10);
        sum += x;
    } else |err| {
    }

    std.debug.warn("{}", sum);
}
