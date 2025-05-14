const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //
    // To use:
    // 1. zig build build-zig to build the zig file
    // 2. zig build build-pdcurses to build the pdcurses.obj file which works differently than the other files
    // 3. zig build build-pdcurses-dll to build the final dll
    // 4. build any other zig program that will attach to the dll
    //

    //
    // Step 2: build .c files in the wincon directory
    //
    // GE: trying to duplicate this command:  windres pdcurses.rc pdcurses.obj
    const pdcurses_obj = b.addSystemCommand(&.{ "windres", "src/pdcurses/common/pdcurses.rc", "src/pdcurses/wincon/pdcurses.obj" });
    const build_pdcurses_step = b.step("build-pdcurses", "Build pdcurses.obj for Windows");
    build_pdcurses_step.dependOn(&pdcurses_obj.step);

    //
    // Step 3: build pdcurses.dll and put it (and pdcurses.a) in the zig-out/lib directory
    //

    //zig cc -Wl,--out-implib,libpdcurses.a -shared -o   pdcurses.dll beep2.obj pdcurses.obj addch.c addchstr.c addstr.c attr.c beep.c bkgd.c border.c
    //clear.c color.c delch.c deleteln.c getch.c getstr.c getyx.c inch.c inchstr.c initscr.c inopts.c insch.c insstr.c instr.c kernel.c keyname.c mouse.c
    //move.c outopts.c overlay.c pad.c panel.c printw.c refresh.c scanw.c scr_dump.c scroll.c slk.c termattr.c touch.c util.c window.c debug.c pdcclip.c
    //pdcdisp.c pdcgetsc.c pdckbd.c pdcscrn.c pdcsetsc.c pdcutil.c
    //
    // FINISHED files: beep.c
    //
    const pdcurses_dll = b.addSystemCommand(&.{
        "zig",
        "cc",
        "-Wl,--out-implib,pdcurses.a",
        "-DPDC_WIDE -DPDC_FORCE_UTF8",
        // "-DGETEST=26",
        "-shared",
        "-o",
        "pdcurses.dll",

        "src/pdcurses/wincon/pdcurses.obj",

        "src/pdcurses/pdcurses/addch.c",
        "src/pdcurses/pdcurses/addchstr.c",
        "src/pdcurses/pdcurses/addstr.c",
        "src/pdcurses/pdcurses/attr.c",
        "src/pdcurses/pdcurses/beep.c",
        "src/pdcurses/pdcurses/bkgd.c",
        "src/pdcurses/pdcurses/border.c",
        "src/pdcurses/pdcurses/clear.c",
        "src/pdcurses/pdcurses/color.c",
        "src/pdcurses/pdcurses/debug.c",
        "src/pdcurses/pdcurses/delch.c",
        "src/pdcurses/pdcurses/deleteln.c",
        "src/pdcurses/pdcurses/getch.c",
        "src/pdcurses/pdcurses/getstr.c",
        "src/pdcurses/pdcurses/getyx.c",
        "src/pdcurses/pdcurses/inch.c",
        "src/pdcurses/pdcurses/inchstr.c",
        "src/pdcurses/pdcurses/initscr.c",
        "src/pdcurses/pdcurses/inopts.c",
        "src/pdcurses/pdcurses/insch.c",
        "src/pdcurses/pdcurses/insstr.c",
        "src/pdcurses/pdcurses/instr.c",
        "src/pdcurses/pdcurses/kernel.c",
        "src/pdcurses/pdcurses/keyname.c",
        "src/pdcurses/pdcurses/mouse.c",
        "src/pdcurses/pdcurses/move.c",
        "src/pdcurses/pdcurses/outopts.c",
        "src/pdcurses/pdcurses/overlay.c",
        "src/pdcurses/pdcurses/pad.c",
        "src/pdcurses/pdcurses/panel.c",
        "src/pdcurses/pdcurses/printw.c",
        "src/pdcurses/pdcurses/refresh.c",
        "src/pdcurses/pdcurses/scanw.c",
        "src/pdcurses/pdcurses/scr_dump.c",
        "src/pdcurses/pdcurses/scroll.c",
        "src/pdcurses/pdcurses/slk.c",
        "src/pdcurses/pdcurses/termattr.c",
        "src/pdcurses/pdcurses/touch.c",
        "src/pdcurses/pdcurses/util.c",
        "src/pdcurses/pdcurses/window.c",

        "src/pdcurses/wincon/pdcclip.c",
        "src/pdcurses/wincon/pdcdisp.c",
        "src/pdcurses/wincon/pdcgetsc.c",
        "src/pdcurses/wincon/pdckbd.c",
        "src/pdcurses/wincon/pdcscrn.c",
        "src/pdcurses/wincon/pdcsetsc.c",
        "src/pdcurses/wincon/pdcutil.c",
    });
    //pdcurses_dll.step.dependOn(&build_pdcurses_step.step);
    const build_dll_step = b.step("build-pdcurses-dll", "Build DLL for Windows");
    build_dll_step.dependOn(&pdcurses_dll.step);

    //
    // Step 4: build my zig file that will link to the dll
    //

    // We will also create a module for our other entry point, 'main.zig'.
    const exe_mod = b.createModule(.{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        //.defineCMacro = .{ "GETEST", "123" }, // TODO: this didn't work
    });

    // This creates another `std.Build.Step.Compile`, but this one builds an executable
    // rather than a static library.
    const exe = b.addExecutable(.{
        .name = "PDCurses",
        .root_module = exe_mod,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
