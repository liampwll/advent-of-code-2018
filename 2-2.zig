const std = @import("std");

const StrAndSum = struct {
    str: []const u8,
    sum: u64,
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    const result = try findCommon(&direct_allocator.allocator, @embedFile("input/2"));
    defer direct_allocator.allocator.free(result);

    std.debug.warn("{}\n", result);
}

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

fn diff(a: []const u8, b: []const u8) usize {
    std.debug.assert(a.len == b.len);

    var n: usize = 0;
    for (a) |x, i| {
        n += @boolToInt(x != b[i]);
    }
    return n;
}

fn findCommon(allocator: *std.mem.Allocator, input: []const u8) ![]u8 {
    var list = std.ArrayList(StrAndSum).init(allocator);
    defer list.deinit();

    var it = std.mem.split(input, "\n");
    while (it.next()) |line| {
        _ = try list.append(StrAndSum{.str = line, .sum = strSum(line)});
    }

    std.sort.sort(StrAndSum, list.toSlice(), cmpBySum);

    for (list.toSlice()) |x, i| {
        for (list.toSlice()[(i + 1)..]) |y| {
            if (y.sum - x.sum <= 26 and diff(x.str, y.str) == 1) {
                const result = try allocator.alloc(u8, x.str.len - 1);
                var j: usize = 0;
                for (x.str) |c, k| {
                    if (c == y.str[k]) {
                        result[j] = c;
                        j += 1;
                    }
                }
                return result;
            }
        }
    }

    unreachable;
}

test "samples" {
    const input =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
        \\fguij
        \\axcye
        \\wvxyz
    ;
    std.debug.assert(std.mem.eql(u8, try findCommon(std.debug.global_allocator, input), "fgij"));
}
