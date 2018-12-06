const std = @import("std");

const max_x = 2000;
const max_y = 2000;

pub fn main() !void {
    std.debug.warn("{}\n", try overlap(@embedFile("input/3")));
}

fn overlap(input: []const u8) !u32 {
    var n: u32 = 0;
    var fabric = [][max_x]u16{[]u16{0} ** max_x} ** max_y;

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        var num_it = std.mem.split(line, "# @,:x");

        const id = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const start_x = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const start_y = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const size_x = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const size_y = try std.fmt.parseInt(u32, num_it.next().?, 10);

        var y = start_y;
        while (y < start_y + size_y) : (y += 1) {
            var x = start_x;
            while (x < start_x + size_x) : (x += 1) {
                if (fabric[y][x] == 1) {
                    n += 1;
                }
                fabric[y][x] += 1;
            }
        }
    }

    return n;
}

test "samples" {
    const input =
        \\#1 @ 1,3: 4x4
        \\#2 @ 3,1: 4x4
        \\#3 @ 5,5: 2x2
    ;
    std.debug.assert((try overlap(input)) == 4);
}
