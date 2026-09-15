const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "BdUnits",
        .root_module = b.createModule(.{
            .root_source_file = b.path("units.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const metricPrefixCompress = b.option(bool, "Compress Metric Prefix", "Compress the Metric Prefix by no compile in compile time") orelse false;

    const options = b.addOptions();
    options.addOption(bool, "metricPrefixCompress", metricPrefixCompress);

    lib.root_module.addOptions("options", options);
    
    b.installArtifact(lib);
}
