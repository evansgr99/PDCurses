// PDCurses

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDCurses/wincon/curspriv.h"); // TODO: change to relative path
});

// man-start**************************************************************
//
// beep
// ----
//
// ### Synopsis
//
//     int beep(void);
//     int flash(void);
//
// ### Description
//
//    beep() sounds the audible bell on the terminal, if possible; if not,
//    it calls flash().
//
//    flash() "flashes" the screen, by inverting the foreground and
//    background of every cell, pausing, and then restoring the original
//    attributes.
//
// ### Return Value
//
//    These functions return ERR if called before initscr(), otherwise OK.
//
// ### Portability
//
//    Function              | X/Open | ncurses | NetBSD
//    :---------------------|:------:|:-------:|:------:
//    beep                  |    Y   |    Y    |   Y
//    flash                 |    Y   |    Y    |   Y
//
// man-end****************************************************************

//
// TODO: 1) each function has a DEBUG macro that hasn't been handled yet,
//       so I can't compile these using DEBUG mode. Work on later.
//
//       2) change @cImport to use relative path instead of absolute path
//

export fn beep() c_int {

    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("beep() - called\n");

    if (c.SP == null)
        return c.ERR;

    if (c.SP.*.audible) {
        c.PDC_beep();
    } else {
        _ = c.flash();
    }

    return c.OK;
}

export fn flash() c_int {
    var z: usize = 0;
    var y: usize = 0;
    var x: usize = 0;

    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("flash() - called\n");

    if (c.curscr == null) return c.ERR;

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
