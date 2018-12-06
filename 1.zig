const std = @import("std");

pub fn main() !void {
    std.debug.warn("{}\n", try freq(@embedFile("input/1")));
}

fn freq(input: []const u8) !i32 {
    var it = std.mem.split(input, "\n");
    var sum: i32 = 0;
    while (it.next()) |line| {
        sum += try std.fmt.parseInt(i32, line, 10);
    }
    return sum;
}

test "samples" {
    std.debug.assert((try freq("+1\n+1\n+1\n")) == 3);
    std.debug.assert((try freq("+1\n+1\n-2\n")) == 0);
    std.debug.assert((try freq("-1\n-2\n-3\n")) == -6);
}
