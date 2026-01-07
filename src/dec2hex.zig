const std = @import("std");

const DivResult = struct {
    quotient: u32,
    remainder: u32,
};

/// Division + Modulo function
/// x: number
/// d: divisor
/// returns DivResult: struct with .quotient, .remainder
fn divmod(x: u32, d: u32) DivResult {
    const quotient = x / d;
    const remainder = x - d * quotient;
    return .{
        .quotient = quotient,
        .remainder = remainder,
    };
}

test "divmod returns correct quotient and remainder" {
    const r = divmod(17, 5);
    try std.testing.expectEqual(@as(u32, 3), r.quotient);
    try std.testing.expectEqual(@as(u32, 2), r.remainder);
}

/// Computes the remainders until the quotient==0
/// Maximum input: 2**32
/// Maximum output: 16**8 -> 8 digits
fn compute_remainders(buf: *[8]u4, x: u32) u4 {
    // initialization
    var quotient: u32 = x;
    var remainder: u32 = undefined;
    var index: u4 = 0;

    // handle edge-case: x is 0!
    if (x == 0) {
        buf[0] = 0;
        index = 1;
    }

    // iteratively compute divmod until quotient is 0
    while (quotient != 0) {
        var results = divmod(quotient, 16);
        quotient = results.quotient;
        remainder = results.remainder;
        buf[index] = @intCast(remainder);
        index += 1;
    }
    return index;
}
/// Maps an unsigned integer (0-15) to its corresponding hexadecimal value
fn hexDigit(n: u4) u8 {
    return switch (n) {
        0...9 => '0' + @as(u8, n),
        10...15 => 'a' + @as(u8, n - 10),
    };
}

test "hexDigit returns correct hex value" {
    try std.testing.expectEqual(@as(u8, 102), hexDigit(15));
    try std.testing.expectEqual(@as(u8, 'f'), hexDigit(15));
    try std.testing.expectEqual(@as(u8, '5'), hexDigit(5));
}

/// Converts an unsigned integer into hexadecimal
pub fn dec2hex(buf_output: *[8]u8, x: u32) []u8 {
    var buf: [8]u4 = undefined;
    const index = compute_remainders(&buf, x);
    const arr_remainders = buf[0..index];
    // std.debug.print("{any}", .{arr_remainders});

    std.mem.reverse(u4, arr_remainders);
    // std.debug.print("{any}", .{arr_remainders});

    //map values into hexDigits
    for (arr_remainders, 0..) |item, i| {
        const hex = hexDigit(item);
        buf_output[i] = hex;
    }

    // return only valid positions of the buffer
    return buf_output[0..index];
}

pub fn main() !void {
    // get list of arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.heap.page_allocator.free(args);

    // sanity check
    if (args.len != 2) {
        std.debug.print("Usage: {s} <int>\n", .{args[0]});
        return;
    }
    // grab first parameter
    const input_str = args[1];

    // parse decimal input into u32
    const x = try std.fmt.parseInt(u32, input_str, 10);

    // std.debug.print("Converting decimal: {d}\n", .{x});
    var buf_output: [8]u8 = undefined;
    const result = dec2hex(&buf_output, x);
    std.debug.print("{s}\n", .{result});
}
