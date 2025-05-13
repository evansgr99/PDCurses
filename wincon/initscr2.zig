const std = @import("std");

const c = @cImport({
    @cInclude("D:/MyDocuments/dv/Github/PDCurses/wincon/curspriv.h"); // TODO: change to relative path
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("string.h");
});

//
// from chat, not sure if I need any of these ===========
//

// const TRUE = 1;
// const FALSE = 0;
// const ERR = -1;
// const OK = 0;

// const SCREEN = ...; // Define based on PDCurses
// const WINDOW = ...; // Define based on PDCurses
// const MOUSE_STATUS = ...;
// const PDC_PAIR = ...;

// const _INBUFSIZ = 512;
// const NUNGETCH = 64;
// const PDC_COLOR_PAIRS = 256;

// extern fn PDC_LOG(msg: [*:0]const u8, ...) void;
// extern fn PDC_scr_open() i32;
// extern fn PDC_get_cursor_mode() i32;
// extern fn PDC_get_rows() i32;
// extern fn PDC_get_columns() i32;
// extern fn newwin(nlines: i32, ncols: i32, begin_y: i32, begin_x: i32) ?*WINDOW;
// extern fn wattrset(win: *WINDOW, ch: u32) void;
// extern fn werase(win: *WINDOW) i32;
// extern fn wclrtobot(win: *WINDOW) i32;
// extern fn untouchwin(win: *WINDOW) void;
// extern fn PDC_slk_initialize() void;
// extern fn def_shell_mode() void;
// extern fn PDC_sysname() [*:0]const u8;
// extern fn PDC_init_atrtab() void;

//
// end chat ===========================
//

// TODO: need to finish this struct
pub const RIPPEDOFFLINE = extern struct { // structure for ripped off lines
    line: c_int,
    //int (*init)(WINDOW *, int); // TODO: how do I translate this?
};

// typedef struct           /* structure for ripped off lines */
// {
//     int line;
//     int (*init)(WINDOW *, int);
// } RIPPEDOFFLINE;

// Zig version of MOUSE_STATUS struct from curses.h
pub const MOUSE_STATUS = extern struct {
    x: c_int, // absolute column, 0 based, measured in characters
    y: c_int, // absolute row, 0 based, measured in characters
    button: [3]c_short, // state of each button
    changes: c_int, // flags indicating what has changed with the mouse
};

// Zig version of PDC_PAIR struct from curses.h
// Color pair structure
pub const PDC_PAIR = extern struct {
    f: c_short, // foreground color
    b: c_short, // background color
    count: c_int, // allocation order
    set: bool, // pair has been set
};

// zig version of WINDOW struct
pub const WINDOW = extern struct { // definition of a window
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

// zig version of SCREEN struct
// TODO: am I handling things like mmask_t and attr_t correctly?
const SCREEN = extern struct {
    alive: bool, // if initscr() called, and not endwin()
    autocr: bool, // if cr -> lf
    cbreak: bool, // if terminal unbuffered
    echo: bool, // if terminal echo
    raw_inp: bool, // raw input mode (v. cooked input)
    raw_out: bool, // raw output mode (7 v. 8 bits)
    audible: bool, // FALSE if the bell is visual
    mono: bool, // TRUE if current screen is mono
    resized: bool, // TRUE if TERM has been resized
    orig_attr: bool, // TRUE if we have the original colors
    orig_fore: c_short, // original screen foreground color
    orig_back: c_short, // original screen foreground color
    cursrow: c_int, // position of physical cursor
    curscol: c_int, // position of physical cursor
    visibility: c_int, // visibility of cursor
    orig_cursor: c_int, // original cursor size
    lines: c_int, // new value for LINES
    cols: c_int, // new value for COLS
    _trap_mbe: c_ulong, // type: mmask_t; trap these mouse button events
    mouse_wait: c_int, // time to wait (in ms) for a button release after a press, in order to count it as a click
    slklines: c_int, // lines in use by slk_init()
    slk_winptr: ?*WINDOW, // window for slk
    linesrippedoff: c_int, // lines ripped off via ripoffline()
    linesrippedoffontop: c_int, // lines ripped off on top via ripoffline()
    delaytenths: c_int, // 1/10ths second to wait block getch() for
    _preserve: bool, // TRUE if screen background to be preserved
    _restore: c_int, // specifies if screen background to be restored, and how
    key_modifiers: c_ulong, // key modifiers (SHIFT, CONTROL, etc.) on last key press
    return_key_modifiers: bool, // TRUE if modifier keys are returned as "real" keys
    key_code: bool, // TRUE if last key is a special key; used internally by get_wch()
    mouse_status: MOUSE_STATUS, // last returned mouse status
    line_color: c_short, // color of line attributes - default -1
    termattrs: c_ulong, // type: attr_t; attribute capabilities
    lastscr: ?*WINDOW, // the last screen image
    dbfp: ?*c.FILE, // debug trace file pointer
    color_started: bool, // TRUE after start_color()
    dirty: bool, // redraw on napms() after init_color()
    sel_start: c_int, // start of selection (y * COLS + x)
    sel_end: c_int, // end of selection
    c_buffer: ?*c_int, // character buffer
    c_pindex: c_int, // putter index
    c_gindex: c_int, // getter index
    c_ungch: ?*c_int, // array of ungotten chars
    c_ungind: c_int, // ungetch() push index
    c_ungmax: c_int, // allocated size of ungetch() buffer
    atrtab: ?*PDC_PAIR, // table of color pairs
};

var ttytype: [128]u8 = undefined;

var SP: ?*SCREEN = null; // curses variables
var curscr: ?*WINDOW = null; // the current screen image
var stdscr: ?*WINDOW = null; // the default screen window

var LINES: c_int = 0; // current terminal height
var COLS: c_int = 0; // current terminal width
var TABSIZE: c_int = 8;

var Mouse_status: MOUSE_STATUS = undefined;

extern var linesripped: [5]c.RIPPEDOFFLINE;
extern var linesrippedoff: u8;

export fn initscr() ?*WINDOW {
    var i: i32 = 0;

    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("initscr() - called\n");

    if (SP != null and SP.*.alive == true)
        return null;

    //SP = @ptrCast(*SCREEN, c.calloc(1, @sizeOf(SCREEN)));

    // GE TODO: use an allocator here?

    const raw_ptr = c.calloc(1, @sizeOf(SCREEN)) orelse {
        std.debug.print("calloc failed\n", .{});
        return;
    };
    SP = @ptrCast(*SCREEN, raw_ptr);

    if (SP == null)
        return null;

    if (c.PDC_scr_open() == c.ERR) {
        _ = c.fprintf(c.stderr, "initscr(): Unable to create SP\n");
        c.exit(8);
    }

    SP.*.autocr = true;
    SP.*.raw_out = false;
    SP.*.raw_inp = false;
    SP.*.cbreak = true;
    SP.*.key_modifiers = 0;
    SP.*.return_key_modifiers = false;
    SP.*.echo = true;
    SP.*.visibility = 1;
    SP.*.resized = false;
    SP.*._trap_mbe = 0;
    SP.*.linesrippedoff = 0;
    SP.*.linesrippedoffontop = 0;
    SP.*.delaytenths = 0;
    SP.*.line_color = -1;
    SP.*.lastscr = null;
    SP.*.dbfp = null;
    SP.*.color_started = false;
    SP.*.dirty = false;
    SP.*.sel_start = -1;
    SP.*.sel_end = -1;

    SP.*.orig_cursor = c.PDC_get_cursor_mode();

    LINES = PDC_get_rows();
    COLS = PDC_get_columns();
    SP.*.lines = LINES;
    SP.*.cols = COLS;

    if (LINES < 2 or COLS < 2) {
        _ = c.fprintf(c.stderr, "initscr(): LINES=%d COLS=%d: too small.\n", LINES, COLS);
        c.exit(4);
    }

    curscr = c.newwin(LINES, COLS, 0, 0);
    if (curscr == null) {
        _ = c.fprintf(c.stderr, "initscr(): Unable to create curscr.\n");
        c.exit(2);
    }

    SP.*.lastscr = c.newwin(LINES, COLS, 0, 0);
    if (SP.*.lastscr == null) {
        _ = c.fprintf(c.stderr, "initscr(): Unable to create SP->lastscr.\n");
        c.exit(2);
    }

    c.wattrset(SP.*.lastscr.*, @bitCast(u32, -1));
    _ = c.werase(SP.*.lastscr.*);

    PDC_slk_initialize();
    LINES -= SP.*.slklines;

    // TODO: implement ripped lines loop

    stdscr = c.newwin(LINES, COLS, SP.*.linesrippedoffontop, 0);
    if (stdscr == null) {
        _ = c.fprintf(c.stderr, "initscr(): Unable to create stdscr.\n");
        c.exit(1);
    }

    _ = c.wclrtobot(stdscr.*);

    if (SP.*.preserve) {
        c.untouchwin(curscr.*);
        c.untouchwin(stdscr.*);
        stdscr.*._clear = false;
        curscr.*._clear = false;
    } else {
        curscr.*._clear = true;
    }

    SP.*.atrtab = @ptrCast([*]PDC_PAIR, c.calloc(c.PDC_COLOR_PAIRS, @sizeOf(PDC_PAIR)));
    if (SP.*.atrtab == null)
        return null;

    c.PDC_init_atrtab();

    // Mouse setup
    Mouse_status.changes = 0;
    // BUTTON_STATUS setup omitted

    SP.*.alive = TRUE;

    def_shell_mode();

    // String format into ttytype buffer
    _ = c.sprintf(&ttytype, "pdcurses|PDCurses for %s", PDC_sysname());

    // Input buffer setup
    SP.*.c_buffer = @ptrCast([*]i32, c.malloc(_INBUFSIZ * @sizeOf(i32)));
    if (SP.*.c_buffer == null)
        return null;
    SP.*.c_pindex = 0;
    SP.*.c_gindex = 1;

    SP.*.c_ungch = @ptrCast([*]i32, c.malloc(NUNGETCH * @sizeOf(i32)));
    if (SP.*.c_ungch == null)
        return null;
    SP.*.c_ungind = 0;
    SP.*.c_ungmax = NUNGETCH;

    return stdscr;
}
