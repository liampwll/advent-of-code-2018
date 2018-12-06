const std = @import("std");

pub fn main() void {
    std.debug.warn("{}\n", checksum(@embedFile("input/2")));
}

fn checksum(input: []const u8) u32 {
    var twos: u32 = 0;
    var threes: u32 = 0;

    var it = std.mem.split(input, "\n");
    while (it.next()) |line| {
        var counts = []u32{0} ** 128;
        for (line) |x| {
            counts[x] += 1;
        }
        var got_two = false;
        var got_three = false;
        for (counts) |x, i| {
            switch (x) {
                2 => if (!got_two) {
                    got_two = true;
                    twos += 1;
                },
                3 => if (!got_three) {
                    got_three = true;
                    threes += 1;
                },
                else => {}
            }
        }
    }

    return twos * threes;
}

test "samples" {
    const input =
        \\abcdef
        \\bababc
        \\abbcde
        \\abcccd
        \\aabcdd
        \\abcdee
        \\ababab
    std.debug.assert(checksum(input) == 12);
}
