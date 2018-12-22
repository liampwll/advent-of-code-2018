const std = @import("std");

const TileKind = enum {
    Rocky = 0,
    Wet = 1,
    Narrow = 2,
    Target,

    pub fn validTool(self: TileKind, tool: ToolKind) bool {
        return switch (self) {
            TileKind.Rocky, TileKind.Target => tool != ToolKind.Neither,
            TileKind.Wet => tool != ToolKind.Torch,
            TileKind.Narrow => tool != ToolKind.Gear
        };
    }
};

const ToolKind = enum {
    Gear,
    Torch,
    Neither
};

const TOOLS = []ToolKind{ToolKind.Gear, ToolKind.Torch, ToolKind.Neither};

const Tile = struct {
    distanceWithTool: [3]u32,
    kind: TileKind
};

const DistanceTile = struct {
    distance: u32,
    y: usize,
    x: usize,
    tool: ToolKind
};

const SIZE = 10000;

pub fn main() !void {
    var direct_allocator = std.heap.DirectAllocator.init();
    defer direct_allocator.deinit();
    var grid = try direct_allocator.allocator.alloc([SIZE]Tile, SIZE);
    defer direct_allocator.allocator.free(grid);

    makeGrid(726, 13, 3066, grid);
    std.debug.warn("{}\n", dijkstra(&direct_allocator.allocator, grid));
}

fn dijkstra(allocator: *std.mem.Allocator, grid: [][SIZE]Tile) !u32 {
    var distance: u32 = 0;
    var heap = std.ArrayList(DistanceTile).init(allocator);
    defer heap.deinit();
    try heapPush(&heap, DistanceTile{.distance = 0, .y = 0, .x = 0, .tool = ToolKind.Torch});

    while (true) {
        const next = heapPop(&heap);

        if (grid[next.y][next.x].kind == TileKind.Target and next.tool == ToolKind.Torch) {
            return next.distance;
        }

        // Same tile with other tool.
        for (TOOLS) |tool| {
            if (grid[next.y][next.x].kind.validTool(tool)
                    and next.distance + 7 < grid[next.y][next.x].distanceWithTool[@enumToInt(tool)]) {
                grid[next.y][next.x].distanceWithTool[@enumToInt(tool)] = next.distance + 7;
                try heapPush(&heap, DistanceTile{.distance = next.distance + 7, .y = next.y, .x = next.x, .tool = tool});
            }
        }

        // Other tiles.
        if (next.y > 0
                and grid[next.y - 1][next.x].kind.validTool(next.tool)
                and next.distance + 1 < grid[next.y - 1][next.x].distanceWithTool[@enumToInt(next.tool)]) {
            grid[next.y - 1][next.x].distanceWithTool[@enumToInt(next.tool)] = next.distance + 1;
            try heapPush(&heap, DistanceTile{.distance = next.distance + 1, .y = next.y - 1, .x = next.x, .tool = next.tool});
        }
        if (next.x > 0
                and grid[next.y][next.x - 1].kind.validTool(next.tool)
                and next.distance + 1 < grid[next.y][next.x - 1].distanceWithTool[@enumToInt(next.tool)]) {
            grid[next.y][next.x - 1].distanceWithTool[@enumToInt(next.tool)] = next.distance + 1;
            try heapPush(&heap, DistanceTile{.distance = next.distance + 1, .y = next.y, .x = next.x - 1, .tool = next.tool});
        }
        if (grid[next.y][next.x + 1].kind.validTool(next.tool)
                and next.distance + 1 < grid[next.y][next.x + 1].distanceWithTool[@enumToInt(next.tool)]) {
            grid[next.y][next.x + 1].distanceWithTool[@enumToInt(next.tool)] = next.distance + 1;
            try heapPush(&heap, DistanceTile{.distance = next.distance + 1, .y = next.y, .x = next.x + 1, .tool = next.tool});
        }
        if (grid[next.y + 1][next.x].kind.validTool(next.tool)
                and next.distance + 1 < grid[next.y + 1][next.x].distanceWithTool[@enumToInt(next.tool)]) {
            grid[next.y][next.x + 1].distanceWithTool[@enumToInt(next.tool)] = next.distance + 1;
            try heapPush(&heap, DistanceTile{.distance = next.distance + 1, .y = next.y + 1, .x = next.x, .tool = next.tool});
        }
    }
}

fn makeGrid(y: u32, x: u32, depth: u32, grid: [][SIZE]Tile) void {
    var i: u32 = 0;
    while (i < grid.len) : (i += 1) {
        var j: u32 = 0;
        while (j < grid[0].len) : (j += 1) {
            const kind = @intToEnum(TileKind, @intCast(@TagType(TileKind), erosionLevel(i, j, y, x, depth) % 3));
            grid[i][j] = Tile{
                .distanceWithTool = []u32{std.math.maxInt(u32)} ** 3,
                .kind = kind
            };
        }
    }

    grid[y][x].kind = TileKind.Target;
}

fn erosionLevel(y: u32, x: u32, target_y: u32, target_x: u32, depth: u32) u32 {
    return (geoIndex(y, x, target_y, target_x, depth) + depth) % 20183;
}

var geoIndexCache = [][SIZE]u32{[]u32{0} ** SIZE} ** SIZE;

fn geoIndex(y: u32, x: u32, target_y: u32, target_x: u32, depth: u32) u32 {
    if (geoIndexCache[y][x] != 0) {
        return geoIndexCache[y][x];
    }
    if (y == 0 and x == 0 or y == target_y and x == target_x) {
        return 0;
    } else if (y == 0) {
        geoIndexCache[y][x] = x * 16807 % 20183;
        return geoIndexCache[y][x];
    } else if (x == 0) {
        geoIndexCache[y][x] = y * 48271 % 20183;
        return geoIndexCache[y][x];
    } else {
        geoIndexCache[y][x] = erosionLevel(y - 1, x, target_y, target_x, depth) * erosionLevel(y, x - 1, target_y, target_x, depth);
        return geoIndexCache[y][x];
    }
}

fn heapPush(list: *std.ArrayList(DistanceTile), item: DistanceTile) !void {
    try list.append(item);
    // I don't want to implement a heap, let's do this instead.
    std.sort.sort(DistanceTile, list.toSlice(), distanceDesc);
}

fn heapPop(list: *std.ArrayList(DistanceTile)) DistanceTile {
    return list.pop();
}

fn distanceDesc(a: DistanceTile, b: DistanceTile) bool {
    return a.distance > b.distance;
}
