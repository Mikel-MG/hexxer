const std = @import("std");
const decoder = @import("hex2dec.zig");
const encoder = @import("dec2hex.zig");

/// this is the help message
fn print_usage() void {
    std.debug.print("Usage: {s} -e|-d \"<string>\"\n", .{"hexxer"});
}

/// this is the main string-encoding function
fn encode_string(allocator: std.mem.Allocator, input_str: []const u8) ![]u8 {
    // allocate buffer for the output
    var buf = try allocator.alloc(u8, input_str.len * 2);

    // iterate through input string and fill the output buffer
    // we have to fill two hex characters per printable ascii)
    for (input_str, 0..) |char, i| {
        var buff: [8]u8 = undefined;
        const hex_encoded_char = encoder.dec2hex(&buff, char);
        // std.debug.print("{s}\n", .{hex_encoded_char});
        buf[2 * i] = hex_encoded_char[0];
        buf[2 * i + 1] = hex_encoded_char[1];
    }

    // return encoded string
    return buf;
}

test "encode_string function returns correct string" {
    const sample_string: []const u8 = "hi this is a test";
    const allocator = std.heap.page_allocator;
    const encoded_string = try encode_string(allocator, sample_string);
    defer allocator.free(encoded_string);
    const expected: []const u8 = "6869207468697320697320612074657374";
    try std.testing.expect(std.mem.eql(u8, encoded_string, expected));
}

/// this is the main string-decoding function
fn decode_string(allocator: std.mem.Allocator, input_str: []const u8) ![]u8 {
    // allocate buffer for the output
    var buf = try allocator.alloc(u8, input_str.len / 2);
    var i: u64 = 0;

    // iterate through input string and fill the output buffer
    // we have to transform two hex characters into one printable ascii
    while (i < input_str.len) {
        const hex_tuple = input_str[i .. i + 2];
        // hex2dec expects a []u8, not []const u8
        var temp_buf: [2]u8 = undefined;
        // we copy the data to mutable memory
        std.mem.copyForwards(u8, &temp_buf, hex_tuple);
        const ascii_char = try decoder.hex2dec(&temp_buf);
        // std.debug.print("{any}\n", .{ascii_char});

        //WARNING: this feels very unsafe
        buf[i / 2] = @intCast(ascii_char);

        i += 2;
    }

    // return encoded string
    return buf;
}

test "decode_string function returns correct string" {
    const sample_hex_string: []const u8 = "7768617420697320746869733f20616e6f74686572207465737421";
    const allocator = std.heap.page_allocator;
    const decoded_string = try decode_string(allocator, sample_hex_string);
    defer allocator.free(decoded_string);
    const expected: []const u8 = "what is this? another test!";
    try std.testing.expect(std.mem.eql(u8, decoded_string, expected));
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    // sanity check
    if (args.len != 3) {
        print_usage();
        return;
    }

    // determine args
    const input_mode = args[1];
    const input_str = args[2];
    // std.debug.print("Input mode: {s}\n", .{input_mode});
    // std.debug.print("Input string: {s}\n", .{input_str});
    // std.debug.print("Input type: {any}\n", .{@TypeOf(input_str)});
    // std.debug.print("Input length: {d}\n", .{input_str.len});

    // encoding mode: ascii -> hex
    if (std.mem.eql(u8, input_mode, "-e")) {
        const encoded_string = try encode_string(allocator, input_str);
        defer allocator.free(encoded_string);
        std.debug.print("{s}\n", .{encoded_string});
    }
    // decoding mode: hex -> ascii
    else if (std.mem.eql(u8, input_mode, "-d")) {
        const decoded_string = try decode_string(allocator, input_str);
        defer allocator.free(decoded_string);
        std.debug.print("{s}\n", .{decoded_string});
    }
    // bad parameter
    else {
        print_usage();
    }
}

test "encoder and decoder are symmetrical operations: 4095" {
    const query_x: u32 = 4095;
    var buf_output: [8]u8 = undefined;
    const hex_val = encoder.dec2hex(&buf_output, query_x);
    const dec_val = try decoder.hex2dec(hex_val);
    try std.testing.expectEqual(query_x, dec_val);
}

test "encoder and decoder are symmetrical operations: 0" {
    const query_x: u32 = 0;
    var buf_output: [8]u8 = undefined;
    const hex_val = encoder.dec2hex(&buf_output, query_x);
    const dec_val = try decoder.hex2dec(hex_val);
    try std.testing.expectEqual(query_x, dec_val);
}
