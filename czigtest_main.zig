const std = @import("std");

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDcurses/ctest.h");
});

fn first_test() void {
    std.debug.print("testing [{d}]\n", .{c.getestnum()});

    std.debug.print("adding: [{d}]\n", .{c.add(2, 40)});
}

pub fn main() !void {
    std.debug.print("starting...\n", .{});

    first_test();
}
