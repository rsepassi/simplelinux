const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "z",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addCSourceFiles(srcs, &.{"-std=c89"});
    b.installArtifact(lib);

    b.getInstallStep().dependOn(&b.addInstallHeaderFile("zlib.h", "zlib.h").step);
    b.getInstallStep().dependOn(&b.addInstallHeaderFile("zconf.h", "zconf.h").step);
}

const srcs = &.{
    "adler32.c",
    "compress.c",
    "crc32.c",
    "deflate.c",
    "gzclose.c",
    "gzlib.c",
    "gzread.c",
    "gzwrite.c",
    "infback.c",
    "inffast.c",
    "inflate.c",
    "inftrees.c",
    "trees.c",
    "uncompr.c",
    "zutil.c",
};
