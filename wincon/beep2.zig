// const std = @import("std");
const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDCurses/wincon/curspriv.h");
    //@cInclude("D:/MyDocuments/dv/Github/PDCurses/wincon/curses.h");
});

export fn beep2() c_int {

    // TODO: macro that only works if DEBUG mode is enabled.  Work on later.
    // PDC_LOG("beep() - called\n");

    if (c.SP == null)
        return c.ERR;

    if (c.SP.*.audible) {
        c.PDC_beep();
    } else {
        _ = c.flash(); // call flash, ignore its return value
    }

    return c.OK;
}

export fn flash2() c_int {
    var z: usize = 0;
    var y: usize = 0;
    var x: usize = 0;

    // TODO: macro that only works if DEBUG mode is enabled.  Work on later.
    // PDC_LOG("flash() - called\n");

    if (c.curscr == null) return c.ERR;

    //const screen = c.curscr.*;

    // Reverse each cell; wait; restore the screen
    while (z < 2) : (z += 1) {
        y = 0;
        while (y < c.LINES) : (y += 1) {
            x = 0;
            while (x < c.COLS) : (x += 1) {
                c.curscr.*._y[y][x] ^= c.A_REVERSE;
            }
        }

        _ = c.wrefresh(c.curscr);

        if (z == 0) {
            _ = c.napms(50);
        }
    }

    return c.OK;
}

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
