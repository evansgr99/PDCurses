# GNU Makefile for PDCurses - Windows console
#
# Usage: make [-f path\Makefile] [DEBUG=Y] [DLL=Y] [WIDE=Y] [UTF8=Y]
#        [INFOEX=N] [tgt]
#
# where tgt can be any of:
# [all|demos|pdcurses.a|testcurs.exe...]




# GE Notes:
#    first, change the first option to 'O = o' and run: ming32-make -f Makefile DLL=Y WIDE=Y UTF8=Y testcurs.exe
#    it should produce a bunch of .obj files, but give an error that it can't produce the .dll or .exe
#    then,  change it to 'O = obj' and run it again
#    it should work the second time

O = obj # GE changed this from 'o' to 'obj' for zig's compiler
E = .exe

ifeq ($(OS),Windows_NT)
	RM = cmd /c del
else
	RM = rm -f
endif

ifndef PDCURSES_SRCDIR
	PDCURSES_SRCDIR = ..
endif

osdir		= $(PDCURSES_SRCDIR)/wincon
common		= $(PDCURSES_SRCDIR)/common

include $(common)/libobjs.mif

PDCURSES_WIN_H	= $(osdir)/pdcwin.h

CC		= zig cc # gcc
AR		= ar
STRIP		= strip
LINK		= zig cc # gcc
WINDRES		= windres

ifeq ($(DEBUG),Y)
	CFLAGS  = -g -Wall -DPDCDEBUG
	LDFLAGS = -g
else
	CFLAGS  = -O2 -Wall
	LDFLAGS =
endif

CFLAGS += -I$(PDCURSES_SRCDIR)
CFLAGS += -Wno-error=date-time # GE added this to elim a warning from the zig cc compiler
# CFLAGS += --verbose # GE added this to elim a warning from the zig cc compiler

ifeq ($(WIDE),Y)
	CFLAGS += -DPDC_WIDE
endif

ifeq ($(UTF8),Y)
	CFLAGS += -DPDC_FORCE_UTF8
endif

# GE changed from pdcurses.o to pdcurses.obj to test zig
ifeq ($(DLL),Y)
	CFLAGS += -DPDC_DLL_BUILD
	LIBEXE = $(CC)
	LIBFLAGS = -Wl,--out-implib,pdcurses.a -shared -o
	LIBCURSES = pdcurses.dll
	CLEAN = $(LIBCURSES) *.a
	RESOURCE = pdcurses.obj 
else
	LIBEXE = $(AR)
	LIBFLAGS = rcv
	LIBCURSES = pdcurses.a
	CLEAN = *.a
endif

ifeq ($(INFOEX),N)
	CFLAGS += -DHAVE_NO_INFOEX
endif

.PHONY: all libs clean demos dist

all:	libs

libs:	$(LIBCURSES)

clean:
	-$(RM) *.o
	-$(RM) *.obj
	-$(RM) *.exe
	-$(RM) *.pdb
	-$(RM) *.dll
	-$(RM) $(CLEAN)

demos:	$(DEMOS)
ifneq ($(DEBUG),Y)
	$(STRIP) *.exe
endif

$(LIBCURSES) : $(LIBOBJS) $(PDCOBJS) $(RESOURCE)
	$(LIBEXE) $(LIBFLAGS) $@ $?

# GE changed from pdcurses.o to pdcurses.obj to test zig
pdcurses.obj: $(common)/pdcurses.rc
	$(WINDRES) -i $(common)/pdcurses.rc pdcurses.obj

$(LIBOBJS) $(PDCOBJS) : $(PDCURSES_HEADERS)
$(PDCOBJS) : $(PDCURSES_WIN_H)
$(DEMOS) : $(PDCURSES_CURSES_H) $(LIBCURSES)
panel.o : $(PANEL_HEADER)

$(LIBOBJS) : %.o: $(srcdir)/%.c
	$(CC) -c $(CFLAGS) $<

$(PDCOBJS) : %.o: $(osdir)/%.c
	$(CC) -c $(CFLAGS) $<

firework.exe ozdemo.exe rain.exe testcurs.exe worm.exe xmas.exe \
ptest.exe: %.exe: $(demodir)/%.c
	$(CC) $(CFLAGS) -o$@ $< $(LIBCURSES)

tuidemo.exe: tuidemo.o tui.o
	$(LINK) $(LDFLAGS) -o$@ tuidemo.o tui.o $(LIBCURSES)

tui.o: $(demodir)/tui.c $(demodir)/tui.h $(PDCURSES_CURSES_H)
	$(CC) -c $(CFLAGS) -I$(demodir) -o$@ $<

tuidemo.o: $(demodir)/tuidemo.c $(PDCURSES_CURSES_H)
	$(CC) -c $(CFLAGS) -I$(demodir) -o$@ $<
