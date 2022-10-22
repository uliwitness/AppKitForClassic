#import "NSTimer.h"
#include <Events.h>
#include <limits.h>
#import "NSArray.h"

#define MAX_TICKS_BETWEEN_EVENT_LOOPS	120

NSMutableArray* gScheduledTimers = nil;

@implementation NSTimer : NSObject

+(id) scheduledTimerWithTimeInterval: (NSTimeInterval)ti target: (id)t selector: (SEL)s userInfo: (id)ui repeats: (BOOL)rep
{
	NSTimer* obj = [[[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceNow: ti] interval: ti
			target: t selector: s userInfo: ui repeats: rep] autorelease];
	[self scheduleTimer: obj];
	return obj;
}


-(id) initWithFireDate: (NSDate*)date interval: (NSTimeInterval)ti
			target: (id)t selector: (SEL)s userInfo: (id)ui
			repeats: (BOOL)rep
{
	self = [super init];
	if( self ) {
		_fireTime = (unsigned long)([date timeIntervalSinceReferenceDate] * 60.0f);
		_interval = (unsigned long)(ti * 60.0f);
		_target = [t retain];
		_selector = s;
		_userInfo = [ui retain];
		_repeats = rep;
	}
	return self;
}

-(void) dealloc
{
	[_target release];
	[_userInfo release];
	
	[super dealloc];
}


-(void) fire
{
	[_target performSelector: _selector withObject: self];
}


-(void) invalidate
{
	[gScheduledTimers removeObjectIdenticalTo: self];
	_fireTime = ULONG_MAX;
}


-(unsigned long) macInterval
{
	return _interval;
}

-(unsigned long) macFireTime
{
	return _fireTime;
}

-(void) setMacFireTime: (unsigned long)newTime
{
	_fireTime = newTime;
}

-(BOOL) repeats
{
	return _repeats;
}


+(void) scheduleTimer: (NSTimer*)t
{
	if( !gScheduledTimers ) {
		gScheduledTimers = [[NSMutableArray alloc] init];
	}
	
	[gScheduledTimers addObject: t];
}

+(unsigned long) fireTimersAt: (unsigned long)currentTime // returns next fire time.
{
	unsigned long nextFireTime;
	unsigned long currentNextFireTime;
	unsigned count, x;
	if( [gScheduledTimers count] == 0 ) {
		return MAX_TICKS_BETWEEN_EVENT_LOOPS;
	}
	
	nextFireTime = ULONG_MAX;
	currentNextFireTime = 0;
	count = [gScheduledTimers count], x;
	for( x = (count -1); x < count; ++x ) {
		NSTimer * currentTimer = [gScheduledTimers objectAtIndex: x];
		if( [currentTimer macFireTime] <= currentTime ) {
			[currentTimer retain];
			[currentTimer fire];
			if( [currentTimer repeats] ) {
				currentNextFireTime = currentTime + [currentTimer macInterval];
			} else {
				currentNextFireTime = ULONG_MAX;
				if( currentNextFireTime == ULONG_MAX && [gScheduledTimers objectAtIndex: x] == currentTimer ) {
					[gScheduledTimers removeObjectAtIndex: x];
				}
			}
			[currentTimer setMacFireTime: currentNextFireTime];
			[currentTimer release];
			nextFireTime = (nextFireTime > currentNextFireTime) ? currentNextFireTime : nextFireTime;
		}
	}
	
	return (nextFireTime > MAX_TICKS_BETWEEN_EVENT_LOOPS) ? MAX_TICKS_BETWEEN_EVENT_LOOPS : nextFireTime;
}

@end