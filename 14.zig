const std = @import("std");

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    for (try scores(&direct_allocator.allocator, 607331)) |x| {
        std.debug.warn("{}", x);
    }
    std.debug.warn("\n");
}

fn scores(allocator: *std.mem.Allocator, input: usize) ![10]u8 {
    var elves = []usize{0, 1};
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try list.appendSlice([]u8{3, 7});

    while (list.count() < input + 10) {
        var sum: u8 = 0;
        for (elves) |elf| {
            sum += list.toSliceConst()[elf];
        }

        const recipes = if (sum / 10 != 0) []u8{sum / 10, sum % 10} else []u8{sum % 10};
        try list.appendSlice(recipes);

        for (elves) |*elf| {
            elf.* = (elf.* + list.toSliceConst()[elf.*] + 1) % list.count();
        }
    }

    var next_ten: [10]u8 = undefined;
    for (list.toSlice()[input..input + 10]) |x, i| {
        next_ten[i] = x;
    }
    return next_ten;
}

test "samples" {
    std.debug.assert(std.mem.eql(u8, try scores(std.debug.global_allocator, 9), []u8{5, 1, 5, 8, 9, 1, 6, 7, 7, 9}));
    std.debug.assert(std.mem.eql(u8, try scores(std.debug.global_allocator, 5), []u8{0, 1, 2, 4, 5, 1, 5, 8, 9, 1}));
    std.debug.assert(std.mem.eql(u8, try scores(std.debug.global_allocator, 18), []u8{9, 2, 5, 1, 0, 7, 1, 0, 8, 5}));
    std.debug.assert(std.mem.eql(u8, try scores(std.debug.global_allocator, 2018), []u8{5, 9, 4, 1, 4, 2, 9, 8, 8, 2}));
}
