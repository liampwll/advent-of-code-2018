const std = @import("std");

const Guard = struct {
    sleep: [60]u32,

    pub fn totalSleep(self: Guard) u32 {
        var total: u32 = 0;
        for (self.sleep) |x| {
            total += x;
        }
        return total;
    }
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try sleepiest(&direct_allocator.allocator, @embedFile("input/4")));
}

fn sleepiest(allocator: *std.mem.Allocator, input: []const u8) !u32 {
    var guards = std.AutoHashMap(u32, Guard).init(allocator);
    defer guards.deinit();

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var line_it = std.mem.split(input, "\n");
    while (line_it.next()) |line| {
        _ = try lines.append(line);
    }

    std.sort.sort([]const u8, lines.toSlice(), lexical);

    var current_guard: *Guard = undefined;
    var last_hour: u32 = 0;
    var last_minute: u32 = 0;
    for (lines.toSlice()) |line| {
        var it = std.mem.split(line, "[]- :#");

        const year = try std.fmt.parseInt(u32, it.next().?, 10);
        const month = try std.fmt.parseInt(u32, it.next().?, 10);
        const day = try std.fmt.parseInt(u32, it.next().?, 10);
        const hour = try std.fmt.parseInt(u32, it.next().?, 10);
        const minute = try std.fmt.parseInt(u32, it.next().?, 10);
        const action = it.next().?;

        switch (action[0]) {
            'G' => { // "Guard"
                const id = try std.fmt.parseInt(u32, it.next().?, 10);
                if (!guards.contains(id)) {
                    _ = try guards.put(id, Guard{.sleep = []u32{0} ** 60});
                }
                current_guard = &guards.get(id).?.value;
            },
            'w' => { // "wakes"
                var i = last_minute;
                while (i < minute) : (i += 1) {
                    current_guard.sleep[i] += 1;
                }
            },
            'f' => { // "falls"
            },
            else => unreachable
        }

        last_minute = minute;
        last_hour = hour;
    }

    var it = guards.iterator();
    var sleepiest_guard = it.next().?;
    while (it.next()) |next| {
        if (next.value.totalSleep() > sleepiest_guard.value.totalSleep()) {
            sleepiest_guard = next;
        }
    }

    var sleepiest_minute: usize = 0;
    for (sleepiest_guard.value.sleep) |count, n| {
        if (count > sleepiest_guard.value.sleep[sleepiest_minute]) {
            sleepiest_minute = n;
        }
    }

    return sleepiest_guard.key * @intCast(u32, sleepiest_minute);
}

fn lexical(a: []const u8, b: []const u8) bool {
    var i: usize = 0;
    while (a[i] == b[i] and i < a.len and i < b.len) : (i += 1) {
    }
    if (i == a.len) {
        return true;
    } else if (i == b.len) {
        return false;
    } else {
        return a[i] <= b[i];
    }
}

test "samples" {
    const input =
        \\[1518-11-01 00:00] Guard #10 begins shift
        \\[1518-11-01 00:05] falls asleep
        \\[1518-11-01 00:25] wakes up
        \\[1518-11-01 00:30] falls asleep
        \\[1518-11-01 00:55] wakes up
        \\[1518-11-01 23:58] Guard #99 begins shift
        \\[1518-11-02 00:40] falls asleep
        \\[1518-11-02 00:50] wakes up
        \\[1518-11-03 00:05] Guard #10 begins shift
        \\[1518-11-03 00:24] falls asleep
        \\[1518-11-03 00:29] wakes up
        \\[1518-11-04 00:02] Guard #99 begins shift
        \\[1518-11-04 00:36] falls asleep
        \\[1518-11-04 00:46] wakes up
        \\[1518-11-05 00:03] Guard #99 begins shift
        \\[1518-11-05 00:45] falls asleep
        \\[1518-11-05 00:55] wakes up
    ;
    std.debug.assert((try sleepiest(std.debug.global_allocator, input)) == 240);
}
