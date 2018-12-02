const std = @import("std");
const io = std.io;
const fmt = std.fmt;

const StrAndSum = struct {
    str: [26]u8,
    sum: u64,
};

fn cmpBySum(a: StrAndSum, b: StrAndSum) bool {
    return std.sort.asc(u64)(a.sum, b.sum);
}

fn strSum(str: []const u8) u64 {
    var sum: u64 = 0;
    for (str) |x| {
        sum += x;
    }
    return sum;
}

fn check(a: []const u8, b: []const u8) bool {
    var diff: usize = 0;
    for (a) |x, i| {
        diff += @boolToInt(x != b[i]);
    }
    return diff <= 1;
}

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    var list = std.ArrayList(StrAndSum).init(&direct_allocator.allocator);
    defer list.deinit();

    var line_buf: [26]u8 = undefined;
    while (io.readLine(line_buf[0..])) |_| {
        _ = try list.append(StrAndSum{.str = line_buf, .sum = strSum(line_buf[0..])});
    } else |err| {
    }

    std.sort.sort(StrAndSum, list.toSlice(), cmpBySum);

    for (list.toSlice()) |x, i| {
        for (list.toSlice()[(i + 1)..]) |y| {
            if (y.sum - x.sum > 26) {
                break;
            }
            if (check(x.str[0..], y.str[0..])) {
                for (x.str) |z, j| {
                    if (z == y.str[j]) {
                        std.debug.warn("{c}", z);
                    }
                }
                std.debug.warn("\n");
            }
        }
    }
}
