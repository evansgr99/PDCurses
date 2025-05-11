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
    // Step 1: build .zig files in the wincon directory
    //
    // GE: trying to duplicate this command:  zig build-obj beep2.zig -lc -target x86_64-windows-gnu
    const beep_obj = b.addSystemCommand(&.{ "zig", "build-obj", "wincon/beep.zig", "-lc", "-target", "x86_64-windows-gnu" });

    // Move the file after it's built
    const move_obj = b.addSystemCommand(&.{ "cmd", "/C", "move", "/Y", "beep.obj", "wincon/beep.obj" });
    move_obj.step.dependOn(&beep_obj.step);

    // delete the extra '.obj.obj' file
    const del_old = b.addSystemCommand(&.{ "cmd", "/C", "del", "beep.obj.obj" });
    del_old.step.dependOn(&move_obj.step);

    const build_beep_step = b.step("build-zig", "Build beep.obj for Windows");
    build_beep_step.dependOn(&del_old.step);

    //
    // move.zig
    //
    const zig_move_obj = b.addSystemCommand(&.{ "zig", "build-obj", "wincon/move2.zig", "-lc", "-target", "x86_64-windows-gnu" });

    // Move the file after it's built
    const move_move_obj = b.addSystemCommand(&.{ "cmd", "/C", "move", "/Y", "move2.obj", "wincon/move2.obj" });
    move_move_obj.step.dependOn(&zig_move_obj.step);

    // delete the extra '.obj.obj' file
    const del_old_move = b.addSystemCommand(&.{ "cmd", "/C", "del", "move2.obj.obj" });
    del_old_move.step.dependOn(&move_move_obj.step);

    const build_move_step = b.step("build-zig2", "Build move.obj for Windows");
    build_move_step.dependOn(&del_old_move.step);

    //
    // Step 2: build .c files in the wincon directory
    //
    // GE: trying to duplicate this command:  windres pdcurses.rc pdcurses.obj
    const pdcurses_obj = b.addSystemCommand(&.{ "windres", "wincon/pdcurses.rc", "wincon/pdcurses.obj" });
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
        "-Wl,--out-implib,zig-out/lib/pdcurses.a",
        "-shared",
        "-o",
        "zig-out/lib/pdcurses.dll",
        "wincon/beep.obj",
        "wincon/move2.obj",
        "wincon/pdcurses.obj",
        "wincon/addch.c",
        "wincon/addchstr.c",
        "wincon/addstr.c",
        "wincon/attr.c",
        "wincon/bkgd.c",
        "wincon/border.c",
        "wincon/clear.c",
        "wincon/color.c",
        "wincon/delch.c",
        "wincon/deleteln.c",
        "wincon/getch.c",
        "wincon/getstr.c",
        "wincon/getyx.c",
        "wincon/inch.c",
        "wincon/inchstr.c",
        "wincon/initscr.c",
        "wincon/inopts.c",
        "wincon/insch.c",
        "wincon/insstr.c",
        "wincon/instr.c",
        "wincon/kernel.c",
        "wincon/keyname.c",
        "wincon/mouse.c",
        "wincon/move.c",
        "wincon/outopts.c",
        "wincon/overlay.c",
        "wincon/pad.c",
        "wincon/panel.c",
        "wincon/printw.c",
        "wincon/refresh.c",
        "wincon/scanw.c",
        "wincon/scr_dump.c",
        "wincon/scroll.c",
        "wincon/slk.c",
        "wincon/termattr.c",
        "wincon/touch.c",
        "wincon/util.c",
        "wincon/window.c",
        "wincon/debug.c",
        "wincon/pdcclip.c",
        "wincon/pdcdisp.c",
        "wincon/pdcgetsc.c",
        "wincon/pdckbd.c",
        "wincon/pdcscrn.c",
        "wincon/pdcsetsc.c",
        "wincon/pdcutil.c",
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
