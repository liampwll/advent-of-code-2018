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

fn react(line: []u8) usize {
    var len = line.len;
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

    return len;
}

fn removeLetter(line: []u8, letter: u8) usize {
    var len = line.len;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        if (toUpper(line[i]) == toUpper(letter)) {
            for (line[(i + 1)..len]) |x, j| {
                line[i + j] = x;
            }
            len -= 1;
            i -= 1;
        }
    }
    return len;
}

pub fn main() !void {
    var line: [50000]u8 = undefined;
    _ = try io.readLine(line[0..]);
    var shortest: usize = 50000;
    var letter: u8 = 'a';
    while (letter <= 'z') : (letter += 1) {
        var line_copy: [50000]u8 = line;
        var len = removeLetter(line_copy[0..], letter);
        len = react(line_copy[0..len]);
        if (len < shortest) {
            shortest = len;
        }
    }

    std.debug.warn("{}\n", shortest);
}
