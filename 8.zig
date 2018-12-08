const std = @import("std");

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try sumMeta(@embedFile("input/8")));
}

fn sumMeta(input: []const u8) !u32 {
    var sum: u32 = 0;
    var it = std.mem.split(input, " \n");
    while (it.index != input.len - 1) {
        sum += try sumMetaInternal(&it);
    }
    return sum;
}

fn sumMetaInternal(it: *std.mem.SplitIterator) (error{
    Overflow,
    InvalidCharacter,
    OutOfMemory,
}!u32) {
    var sum: u32 = 0;

    const n_child = try std.fmt.parseInt(u32, it.next().?, 10);
    const n_meta = try std.fmt.parseInt(u32, it.next().?, 10);

    {var i: u32 = 0; while (i < n_child) : (i += 1) {
        sum += try sumMetaInternal(it);
    }}

    {var i: u32 = 0; while (i < n_meta) : (i += 1) {
        sum += try std.fmt.parseInt(u32, it.next().?, 10);
    }}

    return sum;
}

test "samples" {
    std.debug.assert((try sumMeta("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2\n")) == 138);
}
