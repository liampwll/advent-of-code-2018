const std = @import("std");

pub fn main() void {
    std.debug.warn("{}\n", sumRisk(726, 13, 3066));
}

fn sumRisk(y: u32, x: u32, depth: u32) u32 {
    var sum: u32 = 0;

    var i: u32 = 0;
    while (i <= y) : (i += 1) {
        var j: u32 = 0;
        while (j <= x) : (j += 1) {
            sum += erosionLevel(i, j, y, x, depth) % 3;
        }
    }

    return sum;
}

fn erosionLevel(y: u32, x: u32, target_y: u32, target_x: u32, depth: u32) u32 {
    return (geoIndex(y, x, target_y, target_x, depth) + depth) % 20183;
}

var geoIndexCache = [][800]u32{[]u32{0} ** 800} ** 800;

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
