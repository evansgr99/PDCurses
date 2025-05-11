#include "curses.h"

// extern "C" {
//     void getest(); // Note: C expects the return type and parameter types to match
// }

//pub extern fn flash2() c_int;

int main() {
    printf("hellow world %d \n", getest());

    initscr();
    // flash2();
    printw("helo agn\n");
    getest();
    refresh();
    getch();
    //flash();
    endwin();
    
    return 0;
}