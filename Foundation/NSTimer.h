#import "NSMiniRuntime.h"
#import "NSDate.h"

@interface NSTimer : NSObject
{
	unsigned long _fireTime;
	unsigned long _interval;
	id _target;
	SEL _selector;
	id _userInfo;
	BOOL _repeats;
}

+(id) scheduledTimerWithTimeInterval: (NSTimeInterval)ti target: (id)t selector: (SEL)s userInfo: (id)ui
			repeats: (BOOL)rep;

-(id) initWithFireDate: (NSDate*)date interval: (NSTimeInterval)ti
			target: (id)t selector: (SEL)s userInfo: (id)ui
			repeats: (BOOL)rep;

-(void) fire;
-(void) invalidate;

// nonstandard.
+(void) scheduleTimer: (NSTimer*)t;

// private:
-(BOOL) repeats;

-(unsigned long) macInterval;

-(unsigned long) macFireTime;
-(void) setMacFireTime: (unsigned long)newTime;

+(unsigned long) fireTimersAt: (unsigned long)currentTime; // returns next fire time.

@end
