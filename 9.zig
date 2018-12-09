const std = @import("std");

// Not a real ring buffer/queue/whatever, but it's good enough for this.
fn Ring(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const Error = error{OutOfSpace, NoElements};

        items: []T,
        left: usize,
        right: usize,

        pub fn popLeft(self: *Self) Error!T {
            if (self.items[self.left..self.right].len == 0) {
                return Error.NoElements;
            }
            defer self.left += 1;
            return self.items[self.left];
        }

        pub fn popRight(self: *Self) Error!T {
            if (self.items[self.left..self.right].len == 0) {
                return Error.NoElements;
            }
            defer self.right -= 1;
            return self.items[self.right - 1];
        }

        pub fn pushLeft(self: *Self, item: T) Error!void {
            if (self.left == 0) {
                return Error.OutOfSpace;
            }
            self.left -= 1;
            self.items[self.left] = item;
        }

        pub fn pushRight(self: *Self, item: T) Error!void {
            if (self.right == self.items.len) {
                return Error.OutOfSpace;
            }
            defer self.right += 1;
            self.items[self.right] = item;
        }

        pub fn rotate(self: *Self, n: usize, rightToLeft: bool) Error!void {
            if (self.items[self.left..self.right].len == 0) {
                return Error.NoElements;
            }
            const n_mod = n % (self.items[self.left..self.right].len);
            var i: usize = 0;
            while (i < n_mod) : (i += 1) {
                if (rightToLeft) {
                    try self.pushLeft(try self.popRight());
                } else {
                    try self.pushRight(try self.popLeft());
                }
            }
        }
    };
}

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try highScore(&direct_allocator.allocator, 428, 70825));
    std.debug.warn("{}\n", try highScore(&direct_allocator.allocator, 428, 70825 * 100));
    // std.debug.warn("{}\n", try highScore(&direct_allocator.allocator, 9, 25));
}

fn highScore(allocator: *std.mem.Allocator, players: u32, last_marble: u32) !u32 {
    var ring = Ring(u32){
        .items = try allocator.alloc(u32, @intCast(usize, last_marble) * 6),
        .left = @intCast(usize, last_marble) * 3,
        .right = @intCast(usize, last_marble) * 3
    };
    try ring.pushRight(0);

    var scores = try allocator.alloc(u32, @intCast(usize, players));
    for (scores) |*x| {
        x.* = 0;
    }

    var i: u32 = 1;
    while (i <= last_marble) : (i += 1) {
        if (i % 23 == 0) {
            try ring.rotate(7, true);
            // for (ring.items[ring.left..ring.right]) |x| {
            //     std.debug.warn("{} ", x);
            // }
            // std.debug.warn("!\n");
            scores[i % players] += i;
            scores[i % players] += try ring.popRight();
            try ring.rotate(1, false);
        } else {
            try ring.rotate(1, false);
            try ring.pushRight(i);
        }
        // for (ring.items[ring.left..ring.right]) |x| {
        //     std.debug.warn("{} ", x);
        // }
        // std.debug.warn("\n");
    }

    return std.mem.max(u32, scores);
}
