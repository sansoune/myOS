#include "timer.h"
#include "../../includes/stdio.h"
#include "../../includes/io.h"

int timer_ticks = 0;
int seconds = 0;

int second() {
    return seconds;
}

void timer_handler(Registers* regs) {
      timer_ticks++;
      if(timer_ticks % 18 == 0){
	seconds++;
      }
    return;
}

void sleep(int ticks) {
    int startTicks = timer_ticks;
    while(timer_ticks < startTicks + ticks){}
    return;
}

void init_timer() {
    IRQ_RegisterHandler(0, timer_handler);
}
