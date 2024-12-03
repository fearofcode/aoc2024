const std = @import("std");
const Regex = @import("vendor/zig-regex/regex.zig").Regex;
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const builtin = @import("builtin");

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn part1(allocator: std.mem.Allocator) !void {
    var r = try Regex.compile(allocator, "mul\\(([0-9]{1,3}),([0-9]{1,3})\\)");

    var offset: usize = 0;
    var sum: i64 = 0;
    var lines = split_lines(data);

    while (lines.next()) |line| {
        offset = 0;
        inner: while (true) {
            if (offset >= line.len) break :inner;
            const caps = try r.captures(line[offset..]);
            if (caps) |c| {
                const op1_int = try parseInt(i64, c.sliceAt(1).?, 10);
                const op2_int = try parseInt(i64, c.sliceAt(2).?, 10);
                sum += op1_int * op2_int;
                offset += c.boundsAt(0).?.lower + c.sliceAt(0).?.len;
            } else {
                break :inner;
            }
        }
    }

    std.debug.print("{d}\n", .{sum});
}

pub fn part2(allocator: std.mem.Allocator) !void {
    var r = try Regex.compile(allocator, "mul\\(([0-9]{1,3}),([0-9]{1,3})\\)|do\\(\\)|don't\\(\\)");

    var offset: usize = 0;
    var sum: i64 = 0;
    var lines = split_lines(data);
    var enabled = true;
    while (lines.next()) |line| {
        offset = 0;
        inner: while (true) {
            if (offset >= line.len) break :inner;
            const caps = try r.captures(line[offset..]);
            if (caps) |c| {
                const entireMatch = c.sliceAt(0).?;
                if (std.mem.indexOf(u8, entireMatch, "mul") != null and enabled) {
                    const op1_int = try parseInt(i64, c.sliceAt(1).?, 10);
                    const op2_int = try parseInt(i64, c.sliceAt(2).?, 10);
                    sum += op1_int * op2_int;
                } else if (std.mem.eql(u8, entireMatch, "do()")) {
                    enabled = true;
                } else if (std.mem.eql(u8, entireMatch, "don't()")) {
                    enabled = false;
                }

                offset += c.boundsAt(0).?.lower + c.sliceAt(0).?.len;
            } else {
                break :inner;
            }
        }
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
