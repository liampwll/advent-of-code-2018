const std = @import("std");

const max_x = 2000;
const max_y = 2000;
const max_id: u16 = 2000;

pub fn main() !void {
    std.debug.warn("{}\n", try findValid(@embedFile("input/3")));
}

fn findValid(input: []const u8) !u16 {
    var n: u32 = 0;
    var fabric = [][max_x]u16{[]u16{0} ** max_x} ** max_y;
    var valid_claims = []bool{false} ** max_id;

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        var num_it = std.mem.split(line, "# @,:x");

        const id = try std.fmt.parseInt(u16, num_it.next().?, 10);
        const start_x = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const start_y = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const size_x = try std.fmt.parseInt(u32, num_it.next().?, 10);
        const size_y = try std.fmt.parseInt(u32, num_it.next().?, 10);

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
    }

    for (valid_claims) |is_valid, id| {
        if (is_valid) {
            return @intCast(u16, id);
        }
    }

    unreachable;
}

test "samples" {
    const input =
        \\#1 @ 1,3: 4x4
        \\#2 @ 3,1: 4x4
        \\#3 @ 5,5: 2x2
    ;
    std.debug.assert((try findValid(input)) == 3);
}
