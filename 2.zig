const std = @import("std");
const io = std.io;
const fmt = std.fmt;

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var count_map = std.AutoHashMap(u32, u32).init(&direct_allocator.allocator);
    defer count_map.deinit();

    var line_buf: [100]u8 = undefined;
    while (io.readLine(line_buf[0..])) |line_len| {
        var char_map = std.AutoHashMap(u8, u32).init(&direct_allocator.allocator);
        defer char_map.deinit();

        for (line_buf[0..line_len]) |x| {
            const count = try char_map.getOrPut(x);
            if (count.found_existing == false) {
                count.kv.value = 0;
            }
            count.kv.value += 1;
        }

        var line_count_set = std.AutoHashMap(u32, void).init(&direct_allocator.allocator);
        defer line_count_set.deinit();

        var it = char_map.iterator();
        while (it.next()) |x| {
            if (!line_count_set.contains(x.value)) {
                _ = try line_count_set.put(x.value, {});
                const count = try count_map.getOrPut(x.value);
                if (count.found_existing == false) {
                    count.kv.value = 0;
                }
                count.kv.value += 1;
            }
        }
    } else |err| {
    }

    _ = count_map.remove(1);

    var product: u32 = 1;
    var it = count_map.iterator();
    while (it.next()) |x| {
        std.debug.warn("{} {}\n", x.key, x.value);
        product *= x.value;
    }

    std.debug.warn("{}", product);
}
