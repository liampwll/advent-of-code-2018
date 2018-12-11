const std = @import("std");

pub fn main() void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var res = something(2187);
    std.debug.warn("{},{}\n", res[0], res[1]);
}

fn something(serial: i32) [2]i32 {
    var high: i32 = -2000000000;
    var high_x: i32 = 0;
    var high_y: i32 = 0;

    var y: i32 = 1;
    while (y < 298) : (y += 1) {
        var x: i32 = 1;
        while (x < 298) : (x += 1) {
            var sum = power(x + 0, y + 0, serial)
                + power(x + 1, y + 0, serial)
                + power(x + 2, y + 0, serial)
                + power(x + 0, y + 1, serial)
                + power(x + 1, y + 1, serial)
                + power(x + 2, y + 1, serial)
                + power(x + 0, y + 2, serial)
                + power(x + 1, y + 2, serial)
                + power(x + 2, y + 2, serial);
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
