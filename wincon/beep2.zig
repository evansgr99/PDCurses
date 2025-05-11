// const std = @import("std");
// const c = @cImport({
//     //@cInclude("D:/MyDocuments/dv/Github/PDCurses/curspriv.h");
//     @cInclude("D:/MyDocuments/dv/Github/PDCurses/curses.h");
// });

// const ERR = -1;
// const OK = 0;
// const A_REVERSE = 0x40000000; // Example attribute flag; adjust based on your actual implementation

// const Screen = struct {
//     _y: [][]u32, // assuming 32-bit cells with attributes
// };

// extern fn PDC_LOG(msg: [*:0]const u8) void;
// extern fn wrefresh(screen: *Screen) void;
// extern fn napms(ms: c_int) void;

// export fn flash2() c_int {
//     var z: i32 = 0;
//     var y: i32 = 0;
//     var x: i32 = 0;

//     // TODO: macro that only works if DEBUG mode is enabled.  Work on later.
//     // PDC_LOG("flash() - called\n");

//     if (c.curscr == null) return c.ERR;

//     const screen = c.curscr.?;

//     // Reverse each cell; wait; restore the screen
//     while (z < 2) : (z += 1) {
//         y = 0;
//         while (y < c.LINES) : (y += 1) {
//             x = 0;
//             while (x < c.COLS) : (x += 1) {
//                 screen._y[y][x] ^= c.A_REVERSE;
//             }
//         }

//         c.wrefresh(screen);

//         if (z == 0) {
//             c.napms(50);
//         }
//     }

//     return c.OK;
// }

export fn getest() c_int {
    // std.debug.print("getest() - called\n", .{});
    return 42;
}

// original version below
// int flash(void)
// {
//     int z, y, x;

//     PDC_LOG(("flash() - called\n"));

//     if (!curscr)
//         return ERR;

//     /* Reverse each cell; wait; restore the screen */

//     for (z = 0; z < 2; z++)
//     {
//         for (y = 0; y < LINES; y++)
//             for (x = 0; x < COLS; x++)
//                 curscr->_y[y][x] ^= A_REVERSE;

//         wrefresh(curscr);

//         if (!z)
//             napms(50);
//     }

//     return OK;
// }
