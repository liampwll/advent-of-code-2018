const std = @import("std");

const Instruction = struct {
    op: fn (*State, usize, usize, usize) void,
    a: usize,
    b: usize,
    c: usize
};

const State = struct {
    regs: [6]usize
};

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();

    try cpu(&direct_allocator.allocator, @embedFile("input/21"));
}

fn cpu(allocator: *std.mem.Allocator, input: []const u8) !void {
    var ops = std.hash_map.HashMap(
        []const u8,
        fn (*State, usize, usize, usize) void,
        fnv1a32,
        arrayEql
    ).init(allocator);

    _ = try ops.put("addr"[0..], addr);
    _ = try ops.put("addi"[0..], addi);
    _ = try ops.put("mulr"[0..], mulr);
    _ = try ops.put("muli"[0..], muli);
    _ = try ops.put("banr"[0..], banr);
    _ = try ops.put("bani"[0..], bani);
    _ = try ops.put("borr"[0..], borr);
    _ = try ops.put("bori"[0..], bori);
    _ = try ops.put("setr"[0..], setr);
    _ = try ops.put("seti"[0..], seti);
    _ = try ops.put("gtir"[0..], gtir);
    _ = try ops.put("gtri"[0..], gtri);
    _ = try ops.put("gtrr"[0..], gtrr);
    _ = try ops.put("eqir"[0..], eqir);
    _ = try ops.put("eqri"[0..], eqri);
    _ = try ops.put("eqrr"[0..], eqrr);

    var line_it = std.mem.split(input, "\n");
    const pc_reg = try std.fmt.parseInt(
        usize,
        line_it.next().?[4..5],
        10);

    var program = std.ArrayList(Instruction).init(allocator);

    while (line_it.next()) |line| {
        var split = std.mem.split(line, " ");
        try program.append(Instruction{
            .op = ops.get(split.next().?).?.value,
            .a = try std.fmt.parseInt(usize, split.next().?, 10),
            .b = try std.fmt.parseInt(usize, split.next().?, 10),
            .c = try std.fmt.parseInt(usize, split.next().?, 10)
        });
    }


    var best: u32 = 10000;
    var i: usize = 0;
    while (true) : (i += 1) {
        var state = State{.regs = []usize{i, 0, 0, 0, 0, 0}};
        var counter: u32 = 0;

        while (state.regs[pc_reg] < program.count() and counter < best) : (state.regs[pc_reg] += 1) {
            const inst = program.at(state.regs[pc_reg]);
            inst.op(&state, inst.a, inst.b, inst.c);
            counter += 1;
        }

        if (counter < best) {
            std.debug.warn("{} {}\n", i, counter);
            best = counter;
        }
    }
}

fn addr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] + state.regs[b];
}

fn addi(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] + b;
}

fn mulr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] * state.regs[b];
}

fn muli(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] * b;
}

fn banr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] & state.regs[b];
}

fn bani(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] & b;
}

fn borr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] | state.regs[b];
}

fn bori(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a] | b;
}

fn setr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = state.regs[a];
}

fn seti(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = a;
}

fn gtir(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = @intCast(usize, @boolToInt(a > state.regs[b]));
}

fn gtri(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = @intCast(usize, @boolToInt(state.regs[a] > b));
}

fn gtrr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = @intCast(usize, @boolToInt(state.regs[a] > state.regs[b]));
}

fn eqir(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = @intCast(usize, @boolToInt(a == state.regs[b]));
}

fn eqri(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = @intCast(usize, @boolToInt(state.regs[a] == b));
}

fn eqrr(state: *State, a: usize, b: usize, c: usize) void {
    state.regs[c] = @intCast(usize, @boolToInt(state.regs[a] == state.regs[b]));
}

fn arrayEql(key_a: []const u8, key_b: []const u8) bool {
    for (key_a) |char, i| {
        if (key_b[i] != char) {
            return false;
        }
    }
    return true;
}

fn fnv1a32(key: []const u8) u32 {
    var res: u32 = 2166136261;
    for (key) |char| {
        res = (res ^ @intCast(u32, char)) *% 16777619;
    }
    return res;
}
