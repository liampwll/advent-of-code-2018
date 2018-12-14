const std = @import("std");

pub fn main() void {
    var res = maxPower(2187);
    std.debug.warn("{},{}\n", res[0], res[1]);
}

fn maxPower(serial: i32) [2]i32 {
    var high: i32 = -2000000000;
    var high_x: i32 = 0;
    var high_y: i32 = 0;

    var y: i32 = 1;
    while (y < 298) : (y += 1) {
        var x: i32 = 1;
        while (x < 298) : (x += 1) {
            var sum: i32 = 0;
            var dy: i32 = 0;
            while (dy < 3) : (dy += 1) {
                var dx: i32 = 0;
                while (dx < 3) : (dx += 1) {
                    sum += power(x + dx, y + dy, serial);
                }
            }
            if (sum > high) {
                high = sum;
                high_x = x;
                high_y = y;
            }
        }
    }

    return []i32{high_x, high_y};
}

fn power(x: i32, y: i32, serial: i32) i32 {
    const id = x + 10;
    return @rem(@divTrunc((id * y + serial) * id, 100), 10) - 5;
}

test "samples" {
    std.debug.assert(std.mem.eql(i32, maxPower(18), []i32{33, 45}));
    std.debug.assert(std.mem.eql(i32, maxPower(42), []i32{21, 61}));
}
