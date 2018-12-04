const std = @import("std");
const io = std.io;
const fmt = std.fmt;

const Guard = struct {
     asleep: u32,
    // awake: u32,
    sleep: [60]u32,
};

fn lexical(a: [50]u8, b: [50]u8) bool {
    var i: usize = 0;
    while (a[i] == b[i] and i < a.len) : (i += 1) {
    }
    return a[i] <= b[i];
}

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var map = std.AutoHashMap(u32, Guard).init(&direct_allocator.allocator);
    defer map.deinit();

    var lines = std.ArrayList([50]u8).init(&direct_allocator.allocator);
    defer lines.deinit();

    var guard: *Guard = undefined;
    var last_hour: u32 = 0;
    var last_minute: u32 = 0;
    var asleep: bool = false;

    var line_buf: [50]u8 = undefined;
    while (io.readLine(line_buf[0..])) |_| {
        _ = try lines.append(line_buf);
    } else |err| {
    }

    std.sort.sort([50]u8, lines.toSlice(), lexical);

    for (lines.toSlice()) |line| {
        var iter = std.mem.split(line[0..], "[]- :#");
        const year = try fmt.parseInt(u32, iter.next().?, 10);
        const month = try fmt.parseInt(u32, iter.next().?, 10);
        const day = try fmt.parseInt(u32, iter.next().?, 10);
        const hour = try fmt.parseInt(u32, iter.next().?, 10);
        const minute = try fmt.parseInt(u32, iter.next().?, 10);
        const action = iter.next().?;
        if (std.mem.eql(u8, "Guard", action)) {
            const id = try fmt.parseInt(u32, iter.next().?, 10);
            if (!map.contains(id)) {
                _ = try map.put(id, Guard{.asleep = 0, .sleep = []u32{0} ** 60});
            }
            guard = &map.get(id).?.value;
            asleep = false;
        } else {
            if (asleep) {
                var i = last_minute;
                while (i < minute) : (i += 1) {
                    guard.asleep += 1;
                    guard.sleep[i] += 1;
                }
            }

            if (std.mem.eql(u8, "wakes", action)) {
                asleep = false;
            } else {
                asleep = true;
            }
        }
        last_minute = minute;
        last_hour = hour;
    }

    var it = map.iterator();
    var sleepiest_guard = it.next().?;
    var sleepiest_minute: usize = 0;
    while (it.next()) |next| {
        for (next.value.sleep) |count, n| {
            if (count > sleepiest_guard.value.sleep[sleepiest_minute]) {
                sleepiest_minute = n;
                sleepiest_guard = next;
            }
        }
    }

    std.debug.warn("{} {}\n", sleepiest_guard.key, sleepiest_minute);
}
