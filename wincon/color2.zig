const std = @import("std");

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("string.h");
    @cInclude("D:/MyDocuments/dv/Github/PDCurses/wincon/curspriv.h"); // TODO: change to relative path
});

var COLORS: c_int = 0;
var COLOR_PAIRS: c_int = c.PDC_COLOR_PAIRS; // defined in curspriv.h, = 256

var default_colors: bool = false; // FALSE
var first_col: c_short = 0;
var allocnum: c_int = 0;

export fn start_color2() c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("start_color() - called\n");

    if (c.SP == null or c.SP.*.mono)
        return c.ERR;

    c.SP.*.color_started = true;
    _ = c.PDC_set_blink(false); // Also sets COLORS

    if (!default_colors and c.SP.*.orig_attr and c.getenv("PDC_ORIGINAL_COLORS") != null)
        default_colors = true;

    c.PDC_init_atrtab();

    return c.OK;
}

// BUG: init_pair2 is not working, and it could be any of these 3 items.

fn _normalize2(fg: *c_short, bg: *c_short) void {
    if (fg.* == -1)
        fg.* = if (c.SP.*.orig_attr) c.SP.*.orig_fore else c.COLOR_WHITE;

    if (bg.* == -1)
        bg.* = if (c.SP.*.orig_attr) c.SP.*.orig_back else c.COLOR_BLACK;
}

// TODO: not sure about fg2 and bg2 - can I just pass in &fg and &bg?
fn _init_pair_core2(pair: c_short, fg: c_short, bg: c_short) void {
    const _pair: usize = @intCast(pair);
    var p: *c.PDC_PAIR = c.SP.*.atrtab + _pair; // still not sure what this is doing, since zig requires it to be cast to usize.

    var fg2 = fg;
    var bg2 = bg;
    _normalize2(&fg2, &bg2);

    if (p.set) {
        if (p.f != fg2 or p.b != bg2) {
            if (c.curscr != null)
                c.curscr.?.*._clear = true;
        }
    }

    p.f = fg2;
    p.b = bg2;
    p.count = allocnum;
    allocnum += 1;
    p.set = true;
}

export fn init_pair2(pair: c_short, fg: c_short, bg: c_short) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("init_pair() - called: pair %d fg %d bg %d\n", pair, fg, bg);

    if (c.SP == null or !c.SP.*.color_started or pair < 1 or pair >= COLOR_PAIRS or
        fg < first_col or fg >= COLORS or bg < first_col or bg >= COLORS)
        return c.ERR;

    _init_pair_core2(pair, fg, bg);
    return c.OK;
}

export fn has_colors2() bool {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("has_colors() - called\n");
    return c.SP != null and !c.SP.*.mono;
}

export fn init_color2(color: c_short, red: c_short, green: c_short, blue: c_short) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("init_color() - called\n");

    if (c.SP == null or color < 0 or color >= COLORS or !c.PDC_can_change_color() or
        red < -1 or red > 1000 or green < -1 or green > 1000 or blue < -1 or blue > 1000)
        return c.ERR;

    c.SP.*.dirty = true;

    return c.PDC_init_color(color, red, green, blue);
}

export fn color_content2(color: c_short, red: ?*c_short, green: ?*c_short, blue: ?*c_short) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("color_content() - called\n");

    if (color < 0 or color >= COLORS or red == null or green == null or blue == null)
        return c.ERR;

    if (c.PDC_can_change_color())
        return c.PDC_color_content(color, red, green, blue);

    const maxval: c_short = if ((color & 8) != 0) 1000 else 680;

    if (red) |r| {
        r.* = if ((color & c.COLOR_RED) != 0) maxval else 0;
    }

    if (green) |g| {
        g.* = if ((color & c.COLOR_GREEN) != 0) maxval else 0;
    }

    if (blue) |b| {
        b.* = if ((color & c.COLOR_BLUE) != 0) maxval else 0;
    }

    // red.* = if ((color & c.COLOR_RED) != 0) maxval else 0;
    // green.* = if ((color & c.COLOR_GREEN) != 0) maxval else 0;
    // blue.* = if ((color & c.COLOR_BLUE) != 0) maxval else 0;

    return c.OK;
}

export fn can_change_color2() bool {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("can_change_color() - called\n");
    return c.PDC_can_change_color();
}

export fn pair_content2(pair: c_short, fg: ?*c_short, bg: ?*c_short) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("pair_content() - called\n");

    if (pair < 0 or pair >= COLOR_PAIRS or fg == null or bg == null)
        return c.ERR;

    if (fg) |_fg|
        _fg.* = c.SP.*.atrtab[@intCast(pair)].f;

    if (bg) |_bg|
        _bg.* = c.SP.*.atrtab[@intCast(pair)].b;

    return c.OK;
}

export fn assume_default_colors2(f: c_int, b: c_int) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // c.PDC_LOG("assume_default_colors() - called: f %d b %d\n", f, b);

    if (f < -1 or f >= COLORS or b < -1 or b >= COLORS)
        return c.ERR;

    if (c.SP.*.color_started) {
        // const f2: c_short = @intCast(f);
        // const b2: c_short = @intCast(b); TODOL not sure if I need these, or if it is smart enough to work
        _init_pair_core2(0, @intCast(f), @intCast(b));
    }
    return c.OK;
}

export fn use_default_colors2() c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    //c.PDC_LOG("use_default_colors() - called\n");
    default_colors = true;
    first_col = -1;
    return assume_default_colors2(-1, -1);
}

pub fn PDC_set_line_color2(color: c_short) c_int {
    // TODO: macro that only works if DEBUG mode is enabled. Work on later.
    // PDC_LOG("PDC_set_line_color() - called: %d\n", color);

    if (c.SP == null or color < -1 or color >= COLORS)
        return c.ERR;

    c.SP.*.line_color = color;

    return c.OK;
}

export fn PDC_init_atrtab2() void {
    var p: [*]c.PDC_PAIR = c.SP.*.atrtab;
    var i: c_short = 0;
    var fg: c_short = 0;
    var bg: c_short = 0;

    if (c.SP.*.color_started and !default_colors) {
        fg = c.COLOR_WHITE;
        bg = c.COLOR_BLACK;
    } else {
        fg = -1;
        bg = -1;
    }

    _normalize2(&fg, &bg);

    while (i < c.PDC_COLOR_PAIRS) : (i += 1) {
        const _i: usize = @intCast(i);
        p[_i].f = fg;
        p[_i].b = bg;
        p[_i].set = false;
    }
}

export fn free_pair2(pair: c_int) c_int {
    const _pair: usize = @intCast(pair);

    if (pair < 1 or pair >= c.PDC_COLOR_PAIRS or !c.SP.*.atrtab[_pair].set)
        return c.ERR;

    c.SP.*.atrtab[_pair].set = false;
    return c.OK;
}

export fn find_pair2(fg: c_int, bg: c_int) c_int {
    const p = c.SP.*.atrtab;
    var i: c_int = 0;

    while (i < c.PDC_COLOR_PAIRS) : (i += 1) {
        const _i: usize = @intCast(i);
        if (p[_i].set and p[_i].f == fg and p[_i].b == bg)
            return i;
    }

    return -1;
}

fn _find_oldest2() c_int {
    const p = c.SP.*.atrtab;
    var lowind: c_int = 0;
    var lowval: c_int = 0;
    var i: c_int = 1;

    while (i < c.PDC_COLOR_PAIRS) : (i += 1) {
        const _i: usize = @intCast(i);
        if (!p[_i].set)
            return i;

        if (lowval == 0 or p[_i].count < lowval) {
            lowind = i;
            lowval = p[_i].count;
        }
    }

    return lowind;
}

export fn alloc_pair2(fg: c_int, bg: c_int) c_int {
    var i: c_int = find_pair2(fg, bg);
    if (i == -1) {
        i = _find_oldest2();
        if (init_pair2(@intCast(i), @intCast(fg), @intCast(bg)) == c.ERR)
            return -1;
    }
    return i;
}
