// PDCurses

const std = @import("std");

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDCurses/wincon/curspriv.h"); // TODO: change to relative path
});

// man-start**************************************************************
//
// move
// ---
//
// ### Synopsis
//
//     int move(int y, int x);
//     int mvcur(int oldrow, int oldcol, int newrow, int newcol);
//     int wmove(WINDOW *win, int y, int x);
//
// ### Description
//
//    move() and wmove() move the cursor associated with the window to the
//    given location. This does not move the physical cursor of the
//    terminal until refresh() is called. The position specified is
//    relative to the upper left corner of the window, which is (0,0).
//
//    mvcur() moves the physical cursor without updating any window cursor
//    positions.
//
// ### Return Value
//
//    All functions return OK on success and ERR on error.
//
// ### Portability
//
//    Function              | X/Open | ncurses | NetBSD
//    :---------------------|:------:|:-------:|:------:
//    move                  |    Y   |    Y    |   Y
//    mvcur                 |    Y   |    Y    |   Y
//    wmove                 |    Y   |    Y    |   Y
//
// man-end****************************************************************/

//
// TODO: 1) each function has a DEBUG macro that hasn't been handled yet,
//       so I can't compile these using DEBUG mode. Work on later.
//
//       2) change @cImport to use relative path instead of absolute path
//
//       3) finish wmove2(); not sure how to handle WINDOW as a parameter yet
//
//       4) TESTING!  so far, move2 seems to work, but not sure how to test mvcur2
//

// zig version
const WINDOW = extern struct { // definition of a window
    _cury: c_int, // current pseudo-cursor
    _curx: c_int,
    _maxy: c_int, // max window coordinates
    _maxx: c_int,
    _begy: c_int, // origin on screen
    _begx: c_int,
    _flags: c_int, // window properties
    _attrs: c_ulong, // standard attributes and colors
    _bkgd: c_ulong, // background, normally blank
    _clear: bool, // causes clear at next refresh
    _leaveit: bool, // leaves cursor where it is
    _scroll: bool, // allows window scrolling
    _nodelay: bool, // input character wait flag
    _immed: bool, // immediate update flag
    _sync: bool, // synchronise window ancestors
    _use_keypad: bool, // flags keypad key mode active
    _y: [*][*]c_ulong, // pointer to line pointer array
    _firstch: [*]c_int, // first changed character in line
    _lastch: [*]c_int, // last changed character in line
    _tmarg: c_int, // top of scrolling region
    _bmarg: c_int, // bottom of scrolling region
    _delayms: c_int, // milliseconds of delay for getch()
    _parx: c_int, // coords relative to parent (0,0)
    _pary: c_int,
    _parent: ?*WINDOW, // subwin's pointer to parent win

    // used only if this is a pad
    _pad: extern struct { // Pad-properties structure
        _pad_y: c_int,
        _pad_x: c_int,
        _pad_top: c_int,
        _pad_left: c_int,
        _pad_bottom: c_int,
        _pad_right: c_int,
    },
};

export fn move2(y: c_int, x: c_int) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("move() - called: y=%d x=%d\n", y, x);

    if (c.stdscr == null) return c.ERR;

    if (x < 0 or y < 0 or x >= c.stdscr.*._maxx or y >= c.stdscr.*._maxy)
        return c.ERR;

    c.stdscr.*._curx = x;
    c.stdscr.*._cury = y;

    return c.OK;
}

export fn mvcur2(oldrow: c_int, oldcol: c_int, newrow: c_int, newcol: c_int) c_int {
    _ = oldrow;
    _ = oldcol;

    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("mvcur() - called: oldrow %d oldcol %d newrow %d newcol %d\n",
    //    oldrow, oldcol, newrow, newcol);

    if (c.SP == null) return c.ERR;

    if (newrow < 0 or newrow >= c.LINES or newcol < 0 or newcol >= c.COLS)
        return c.ERR;

    c.PDC_gotoyx(newrow, newcol);

    c.SP.*.cursrow = newrow;
    c.SP.*.curscol = newcol;

    return c.OK;
}

export fn wmove2(win: ?*WINDOW, y: c_int, x: c_int) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("wmove() - called: y=%d x=%d\n", y, x);

    if (win == null) return c.ERR;

    if (x < 0 or y < 0 or x >= win.?._maxx or y >= win.?._maxy)
        return c.ERR;

    win.?._curx = x;
    win.?._cury = y;

    return c.OK;
}
