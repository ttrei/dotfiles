const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "xwinpid",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const flags = b.dependency("flags", .{
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("flags", flags.module("flags"));

    exe.linkSystemLibrary("xcb");
    exe.linkSystemLibrary("xcb-res");
    exe.linkSystemLibrary("c");

    b.installArtifact(exe);
}
