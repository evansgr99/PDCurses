const std = @import("std");

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDcurses/wincon/curses.h");
});

// extern fn getest() void;

const KEY_Q: c_int = 113;

fn first_test() void {
    // std.debug.print("GETEST={}", .{c.PDC_WIDE});

    _ = c.initscr(); //  : [*c]win
    _ = c.printw("hello again\n"); // this prints something to the screen, and returns the num of chars it printed
    _ = c.refresh();
    // _ = c.flash(); // testing my custom code - works!
    // _ = c.beep(); // testing my custom code - works!

    _ = c.move(2, 2);

    _ = c.mvcur(5, 5, 5, 5);

    _ = c.wmove(c.stdscr, 10, 10);

    _ = c.refresh();

    _ = c.printw("after movements\n"); // this prints something to the screen, and returns the num of chars it printed

    _ = c.wmove(c.stdscr, 7, 18);

    _ = c.refresh();

    _ = c.printw("after movements\n"); // this prints something to the screen, and returns the num of chars it printed

    if (c.has_colors()) {
        _ = c.start_color();
        _ = c.init_pair(16, c.COLOR_CYAN, c.COLOR_RED);
        _ = c.attron(c.COLOR_PAIR(16));
        _ = c.printw("some more colored text");
        _ = c.attroff(c.COLOR_PAIR(16));
        _ = c.refresh();
    } else {
        _ = c.printw("still can't do colors");
    }

    const key_input: c_int = c.getch();
    std.debug.print("got key [{d}]\n", .{key_input});

    //std.debug.print("chtype={}", .{@sizeOf(c.chtype)});

    _ = c.endwin();
}

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"hell yeah!"});

    first_test();
}
