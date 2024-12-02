const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const builtin = @import("builtin");

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn part1(allocator: std.mem.Allocator) !void {
    var lines = split_lines(data);
    const lines_len = line_count(data);

    var lhs = try std.ArrayList(i64).initCapacity(allocator, lines_len);
    var rhs = try std.ArrayList(i64).initCapacity(allocator, lines_len);

    while (lines.next()) |line| {
        var tokens = splitAny(u8, line, " ");
        var appending_lhs = true;
        var appending_rhs = false;
        while (tokens.next()) |token| {
            if (token.len == 0) continue;

            if (appending_lhs) {
                try lhs.append(try parseInt(i64, token, 10));
                appending_lhs = false;
                appending_rhs = true;
            } else if (appending_rhs) {
                try rhs.append(try parseInt(i64, token, 10));
                appending_rhs = false;
            }
        }
    }

    std.mem.sort(i64, lhs.items, {}, std.sort.asc(i64));
    std.mem.sort(i64, rhs.items, {}, std.sort.asc(i64));

    var i: usize = 0;
    var sum: usize = 0;
    while (i < lhs.items.len) : (i += 1) {
        sum += @abs(lhs.items[i] - rhs.items[i]);
    }
    std.debug.print("{d}\n", .{sum});
}

pub fn part2(allocator: std.mem.Allocator) !void {
    var lines = split_lines(data);
    const lines_len = line_count(data);

    var lhs = try std.ArrayList(i64).initCapacity(allocator, lines_len);
    var rhs = try std.ArrayList(i64).initCapacity(allocator, lines_len);

    while (lines.next()) |line| {
        var tokens = splitAny(u8, line, " ");
        var appending_lhs = true;
        var appending_rhs = false;
        while (tokens.next()) |token| {
            if (token.len == 0) continue;

            if (appending_lhs) {
                try lhs.append(try parseInt(i64, token, 10));
                appending_lhs = false;
                appending_rhs = true;
            } else if (appending_rhs) {
                try rhs.append(try parseInt(i64, token, 10));
                appending_rhs = false;
            }
        }
    }

    var counts = std.AutoHashMap(i64, i64).init(allocator);

    var i: usize = 0;
    for (rhs.items) |item| {
        const c = counts.get(item) orelse 0;
        try counts.put(item, c + 1);
    }

    var sum: i64 = 0;
    i = 0;
    while (i < lhs.items.len) : (i += 1) {
        const lhs_item = lhs.items[i];
        const rhs_count = counts.get(lhs_item) orelse 0;
        sum += lhs_item * rhs_count;
    }
    std.debug.print("{d}\n", .{sum});
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
