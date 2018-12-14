const std = @import("std");

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    std.debug.warn("{}\n", try findFirst(&direct_allocator.allocator, []u8{6, 0, 7, 3, 3, 1}));
}

fn findFirst(allocator: *std.mem.Allocator, input: []const u8) !usize {
    var elves = []usize{0, 1};
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try list.appendSlice([]u8{3, 7});

    while (true) {
        var sum: u8 = 0;
        for (elves) |elf| {
            sum += list.toSliceConst()[elf];
        }

        const recipes = if (sum / 10 != 0) []u8{sum / 10, sum % 10} else []u8{sum % 10};
        for (recipes) |recipe| {
            try list.append(recipe);
            if (list.count() >= input.len and std.mem.eql(u8, input, list.toSliceConst()[list.count() - input.len..])) {
                return list.count() - input.len;
            }
        }

        for (elves) |*elf| {
            elf.* = (elf.* + list.toSliceConst()[elf.*] + 1) % list.count();
        }
    }
}

test "samples" {
    std.debug.assert((try findFirst(std.debug.global_allocator, []u8{5, 1, 5, 8, 9})) == 9);
    std.debug.assert((try findFirst(std.debug.global_allocator, []u8{0, 1, 2, 4, 5})) == 5);
    std.debug.assert((try findFirst(std.debug.global_allocator, []u8{9, 2, 5, 1, 0})) == 18);
    std.debug.assert((try findFirst(std.debug.global_allocator, []u8{5, 9, 4, 1, 4})) == 2018);
}
