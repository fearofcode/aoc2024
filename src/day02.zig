const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const builtin = @import("builtin");

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn part1(allocator: std.mem.Allocator) !void {
    var lines = split_lines(data);
    var levels = try std.ArrayList(i64).initCapacity(allocator, 16);

    var safe_count: usize = 0;

    while (lines.next()) |line| {
        // std.debug.print("\nline = {s}\n", .{line});
        levels.clearRetainingCapacity();
        var tokens = tokenizeAny(u8, line, " ");
        while (tokens.next()) |token| {
            try levels.append(try parseInt(i64, token, 10));
        }

        if (level_safe(levels.items)) {
            safe_count += 1;
        }
    }

    std.debug.print("{d}\n", .{safe_count});
}

pub fn level_safe(levels: []i64) bool {
    var increasing = true;
    var decreasing = true;

    // check if increasing
    var pairs = std.mem.window(i64, levels, 2, 1);
    while (pairs.next()) |pair| {
        if (pair[1] < pair[0]) {
            increasing = false;
            // std.debug.print("not increasing\n", .{});
            break;
        }
    }
    // check if decreasing
    pairs = std.mem.window(i64, levels, 2, 1);
    while (pairs.next()) |pair| {
        if (pair[1] > pair[0]) {
            decreasing = false;
            // std.debug.print("not decreasing\n", .{});
            break;
        }
    }

    if (!increasing and !decreasing) {
        return false;
    }

    pairs = std.mem.window(i64, levels, 2, 1);

    while (pairs.next()) |pair| {
        const difference = @abs(pair[0] - pair[1]);
        if (difference < 1 or difference > 3) {
            return false;
        }
    }

    return true;
}

pub fn part2(allocator: std.mem.Allocator) !void {
    var lines = split_lines(data);
    var levels = try std.ArrayList(i64).initCapacity(allocator, 16);

    var safe_count: usize = 0;

    while (lines.next()) |line| {
        // std.debug.print("\nline = {s}\n", .{line});
        levels.clearRetainingCapacity();
        var tokens = tokenizeAny(u8, line, " ");
        while (tokens.next()) |token| {
            try levels.append(try parseInt(i64, token, 10));
        }

        // safe without removal
        if (level_safe(levels.items)) {
            // std.debug.print("line {s} is safe without removal\n", .{line});
            safe_count += 1;
            continue;
        }

        var remove_idx: usize = 0;
        while (remove_idx < levels.items.len) : (remove_idx += 1) {
            // std.debug.print("remove_idx = {d}\n", .{remove_idx});
            var alternate_level = try levels.clone();
            _ = alternate_level.orderedRemove(remove_idx);

            if (level_safe(alternate_level.items)) {
                // std.debug.print("line {s} is safe if you remove index {d}\n", .{ line, remove_idx });
                safe_count += 1;
                break;
            }
        }
    }

    std.debug.print("{d}\n", .{safe_count});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try part2(allocator);
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

pub fn line_words(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList([]const u8) {
    var it = std.mem.splitAny(u8, buffer, " ");
    var words = std.ArrayList([]const u8).init(allocator);
    while (it.next()) |word| {
        try words.append(word);
    }

    return words;
}

pub fn split_lines(input: []const u8) std.mem.SplitIterator(u8, .sequence) {
    const line_delimeters = if (builtin.os.tag == .windows) "\r\n" else "\n";

    return std.mem.splitSequence(u8, input, line_delimeters);
}

pub fn line_count(input: []const u8) usize {
    var lines = split_lines(input);
    var line_cnt: usize = 0;
    while (lines.next()) |line| : (line_cnt += 1) {
        _ = line;
    }
    return line_cnt;
}

pub fn parse_u64(buf: []const u8) !u64 {
    return try std.fmt.parseInt(u64, buf, 10);
}

pub fn parse_f64(buf: []const u8) std.fmt.ParseIntError!f64 {
    return try std.fmt.parseFloat(f64, buf);
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
