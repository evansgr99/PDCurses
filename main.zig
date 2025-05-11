const std = @import("std");

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDcurses/wincon/curses.h");
});

// extern fn getest() void;

const KEY_Q: c_int = 113;

fn first_test() void {
    _ = c.initscr(); //  : [*c]win
    _ = c.printw("hello again\n"); // this prints something to the screen, and returns the num of chars it printed
    _ = c.refresh();
    // _ = c.flash(); // testing my custom code - works!
    // _ = c.beep(); // testing my custom code - works!

    const res = c.move2(2, 2);
    std.debug.print("got return valu from move2 [{d}]\n", .{res});

    const res2 = c.mvcur2(5, 5, 5, 5);
    std.debug.print("got return valu from mvcur2 [{d}]\n", .{res2});

    _ = c.refresh();

    _ = c.printw("after movements\n"); // this prints something to the screen, and returns the num of chars it printed

    const key_input: c_int = c.getch();
    std.debug.print("got key [{d}]\n", .{key_input});

    _ = c.endwin();
}

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"hell yeah!"});

    first_test();
}
