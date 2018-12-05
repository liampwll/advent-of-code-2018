const std = @import("std");
const io = std.io;
const fmt = std.fmt;

fn toUpper(x: u8) u8 {
    if (x >= 'a' and 'z' >= x) {
        return x - ('a' - 'A');
    } else {
        return x;
    }
}

pub fn main() !void {
    var len: usize = 50000;
    var line: [50000]u8 = undefined;
    _ = try io.readLine(line[0..]);
    outer: while (true) {
        for (line[0..(len - 1)]) |x, i| {
            if (toUpper(x) == toUpper(line[i + 1]) and x != line[i + 1]) {
                for (line[(i + 2)..len]) |y, j| {
                    line[i + j] = y;
                }
                len -= 2;
                continue :outer;
            }
        }
        break;
    }

    std.debug.warn("{}\n", len);
}
