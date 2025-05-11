const std = @import("std");

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDcurses/curses.h");
});

// extern fn getest() void;

const KEY_Q: c_int = 113;

fn first_test() void {
    const win = c.initscr(); //  : [*c]win

    // this prints something to the screen, and returns the num of chars it printed
    const test_int: c_int = c.printw("hello again\n");
    _ = test_int;
    // std.debug.print("return val of printw={d}", .{test_int});

    _ = c.refresh();

    const key_input: c_int = c.getch();

    std.debug.print("got key [{d}]", .{key_input});

    const ew: c_int = c.endwin();
    std.debug.print("got endwin [{d}]", .{ew});

    _ = win;
    // _ = c;
    const x = c.getest();
    std.debug.print("d is {d}.\n", .{x});
}

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"hell yeah!"});

    first_test();
}
