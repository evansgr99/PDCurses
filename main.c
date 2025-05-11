#include "curses.h"

int main() {
    printf("hellow world\n");

    initscr();
    printw("helo agn\n");
    refresh();
    getch();
    endwin();
    
    return 0;
}