const std = @import("std");

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    std.debug.warn("{}\n", try react(&direct_allocator.allocator, @embedFile("input/5")));
}

fn react(allocator: *std.mem.Allocator, input: []const u8) !usize {
    var shortest = input.len;

    var letter: u8 = 'A';
    while (letter < 'Z') : (letter += 1) {
        var stack = std.ArrayList(u8).init(allocator);
        defer stack.deinit();

        for (input) |x| {
            if (isAlpha(x) and toUpper(x) != letter) {
                _ = try stack.append(x);
            }
            while (stack.count() >= 2 and canReact(stack.at(stack.count() - 1), stack.at(stack.count() - 2))) {
                _ = stack.pop();
                _ = stack.pop();
            }
        }

        if (stack.count() < shortest) {
            shortest = stack.count();
        }
    }

    return shortest;
}

fn canReact(a: u8, b: u8) bool {
    return toUpper(a) == toUpper(b) and a != b;
}

fn toUpper(x: u8) u8 {
    if ('a' <= x and x <= 'z') {
        return x - ('a' - 'A');
    } else {
        return x;
    }
}

fn isAlpha(x: u8) bool {
    return 'a' <= x and x <= 'z' or 'A' <= x and x <= 'Z';
}

test "samples" {
    std.debug.assert((try react(std.debug.global_allocator, "dabAcCaCBAcCcaDA")) == 4);
}
