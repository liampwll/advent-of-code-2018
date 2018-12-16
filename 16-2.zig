const std = @import("std");

const Instruction = struct {
    opcode: usize,
    a: usize,
    b: usize,
    c: usize
};

const State = struct {
    regs: [4]usize
};

const UnmatchedOp = struct {
    id: usize,
    matches: [16]bool
};

pub fn main() !void {
    std.debug.warn("{}\n", try something(@embedFile("input/16"), @embedFile("input/16-2")));
}

fn something(input: []const u8, input2: []const u8) !usize {
    var matches: [16]UnmatchedOp = undefined;
    for (matches) |*x, i| {
        x.* = UnmatchedOp{.id = i, .matches = []bool{true} ** 16};
    }
    {var line_it = std.mem.split(input, "\n"); while (line_it.next()) |line| {
        var before_line = std.mem.split(line, "Before: [,]");
        var before_state: State = undefined;
        {var i: usize = 0; while (before_line.next()) |reg| {
            before_state.regs[i] = try std.fmt.parseInt(usize, reg, 10);
            i += 1;
        }}

        var instruction_line = std.mem.split(line_it.next().?, " ");
        const instruction = Instruction{
            .opcode = try std.fmt.parseInt(usize, instruction_line.next().?, 10),
            .a = try std.fmt.parseInt(usize, instruction_line.next().?, 10),
            .b = try std.fmt.parseInt(usize, instruction_line.next().?, 10),
            .c = try std.fmt.parseInt(usize, instruction_line.next().?, 10)
        };

        var after_line = std.mem.split(line_it.next().?, "After: [,]");
        var after_state: State = undefined;
        {var i: usize = 0; while (after_line.next()) |reg| {
            after_state.regs[i] = try std.fmt.parseInt(usize, reg, 10);
            i += 1;
        }}

        for (OPS) |op, i| {
            var state = before_state;
            op(&state, instruction.a, instruction.b, instruction.c);
            if (!std.mem.eql(usize, state.regs, after_state.regs)) {
                matches[instruction.opcode].matches[i] = false;
            }
        }
    }}

    var sorted_ops: [16]fn (*State, usize, usize, usize) void = undefined;

    // This doesn't work for all inputs, but it works for my input.
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        std.sort.sort(UnmatchedOp, matches[i..], sortByCount);
        var id: usize = 9999;
        for (matches[i].matches) |x, j| {
            if (x) {
                id = j;
            }
        }

        sorted_ops[matches[i].id] = OPS[id];
        for (matches[i..]) |*x| {
            x.matches[id] = false;
        }
    }

    var state: State = undefined;
    {var line_it = std.mem.split(input2, "\n"); while (line_it.next()) |line| {
        var instruction_line = std.mem.split(line, " ");
        const instruction = Instruction{
            .opcode = try std.fmt.parseInt(usize, instruction_line.next().?, 10),
            .a = try std.fmt.parseInt(usize, instruction_line.next().?, 10),
            .b = try std.fmt.parseInt(usize, instruction_line.next().?, 10),
            .c = try std.fmt.parseInt(usize, instruction_line.next().?, 10)
        };

        sorted_ops[instruction.opcode](&state, instruction.a, instruction.b, instruction.c);
    }}

    return state.regs[0];
}

fn sortByCount(a: UnmatchedOp, b: UnmatchedOp) bool {
    var na: usize = 0;
    for (a.matches) |x| {
        if (x) {
            na += 1;
        }
    }

    var nb: usize = 0;
    for (b.matches) |x| {
        if (x) {
            nb += 1;
        }
    }

    return na < nb;
}

const OPS = []fn (*State, usize, usize, usize) void
    {addr, addi, mulr, muli, banr, bani, borr, bori,
     setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr};

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
