const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -----------------------------------------

    const path_hex2dec = b.path("src/hex2dec.zig");

    const exe_hex2dec = b.addExecutable(.{
        .name = "hex2dec",
        .root_module = b.createModule(.{
            .root_source_file = path_hex2dec,
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe_hex2dec);

    // -----------------------------------------

    const path_dec2hex = b.path("src/dec2hex.zig");

    const exe_dec2hex = b.addExecutable(.{
        .name = "dec2hex",
        .root_module = b.createModule(.{
            .root_source_file = path_dec2hex,
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe_dec2hex);

    // -----------------------------------------

    const path_hexxer = b.path("src/main.zig");

    const exe_hexxer = b.addExecutable(.{
        .name = "hexxer",
        .root_module = b.createModule(.{
            .root_source_file = path_hexxer,
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe_hexxer);

    // -----------------------------------------

    const test_step = b.step("test", "Run all tests");

    const test_hex2dec = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = path_hex2dec,
        .target = target,
        .optimize = optimize,
    }) });

    const test_dec2hex = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = path_dec2hex,
        .target = target,
        .optimize = optimize,
    }) });

    const test_hexxer = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = path_hexxer,
        .target = target,
        .optimize = optimize,
    }) });

    const run_hex2dec_tests = b.addRunArtifact(test_hex2dec);
    const run_dec2hex_tests = b.addRunArtifact(test_dec2hex);
    const run_hexxer_tests = b.addRunArtifact(test_hexxer);

    test_step.dependOn(&run_hex2dec_tests.step);
    test_step.dependOn(&run_dec2hex_tests.step);
    test_step.dependOn(&run_hexxer_tests.step);
}
