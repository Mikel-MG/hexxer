const std = @import("std");

const Error = error{InvalidHexDigit};

/// maps a string character (hex value) to an unsigned integer (0-15)
fn hexDigit2Dec(c: u8) !u4 {
    return switch (c) {
        '0'...'9' => @intCast(c - '0'),
        'a'...'f' => @intCast(c - 'a' + 10),
        else => Error.InvalidHexDigit,
    };
}

test "hexDigit2Dec returns correct int value" {
    try std.testing.expectEqual(@as(u4, 0), hexDigit2Dec('0'));
    try std.testing.expectEqual(@as(u4, 5), hexDigit2Dec('5'));
    try std.testing.expectEqual(@as(u4, 15), hexDigit2Dec('f'));
}

/// transforms a number from hexadecimal to decimal representation
pub fn hex2dec(arr_hex: []u8) !u32 {
    // this will store each component to produce the target decimal value
    var sum_components: u32 = 0;

    // reverse the components so that the indices equate the power
    std.mem.reverse(u8, arr_hex);

    // iterate through each character and compute the component
    for (arr_hex, 0..) |item, i| {
        // std.debug.print("Reading: {d}->{c}\n", .{ i, item });
        const coef: u4 = try hexDigit2Dec(item);
        const comp: u32 = @as(u32, coef) * std.math.pow(u32, 16, @intCast(i));
        sum_components += comp;
    }
    return sum_components;
}

test "hex2dec returns correct int value" {
    var arr1 = [_]u8{ 'f', 'f' };
    try std.testing.expectEqual(@as(u32, 255), hex2dec(arr1[0..]));

    var arr2 = [_]u8{ 'f', 'f', 'f' };
    try std.testing.expectEqual(@as(u32, 4095), hex2dec(arr2[0..]));

    var arr3 = [_]u8{'0'};
    try std.testing.expectEqual(@as(u32, 0), hex2dec(arr3[0..]));
}

pub fn main() !void {
    // get list of arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.heap.page_allocator.free(args);

    // sanity check
    if (args.len != 2) {
        std.debug.print("Usage: {s} <hex>\n", .{args[0]});
        return;
    }
    // grab first parameter
    const input_str = args[1];

    // compute result
    const result = try hex2dec(input_str);
    std.debug.print("{d}\n", .{result});
}
