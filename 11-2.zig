const std = @import("std");

pub fn main() void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var res = something(2187);
    std.debug.warn("{},{},{}\n", res[0], res[1], res[2]);
}

fn something(serial: i32) [3]i32 {
    var high: i32 = -2000000000;
    var high_x: i32 = 0;
    var high_y: i32 = 0;
    var high_size: i32 = 0;

    var y: i32 = 1;
    while (y <= 300) : (y += 1) {
        std.debug.warn("{}\n", y);
        var x: i32 = 1;
        while (x <= 300) : (x += 1) {
            const max_size = std.math.min(301 - x, 301 - y);
            var size: i32 = 1;
            while (size <= max_size) : (size += 1) {
                var sum: i32 = 0;
                var y2: i32 = 0;
                while (y2 < size) : (y2 += 1) {
                    var x2: i32 = 0;
                    while (x2 < size) : (x2 += 1) {
                        sum += power(x + x2, y + y2, serial);
                    }
                }
                if (sum > high) {
                    high = sum;
                    high_x = x;
                    high_y = y;
                    high_size = size;
                }
            }
        }
    }

    return []i32{high_x, high_y, high_size};
}

fn power(x: i32, y: i32, serial: i32) i32 {
    const id = x + 10;
    return @rem(@divTrunc((id * y + serial) * id, 100), 10) - 5;
}
