#import "Runtime.h"
(id) scheduledTimerWithTimeInterval: (NSTimeInterval)ti target: (id)t selector: (SEL)s userInfo: (id)ui
(void) scheduleTimer: (NSTimer*)t;
(unsigned long) fireTimersAt: (unsigned long)currentTime; // returns next fire time.