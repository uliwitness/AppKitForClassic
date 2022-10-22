#import "NSTimer.h"
#include <Events.h>

@implementation NSDate : NSObject

+(id) currentDate
{
	NSDate * now = [[[self alloc] init] autorelease];
	now->_ticksSinceStartup = TickCount();
	return now;
}

+(id) dateWithTimeIntervalSinceNow: (NSTimeInterval)ti
{
	NSDate * soon = [[[self alloc] init] autorelease];
	soon->_ticksSinceStartup = TickCount() + (unsigned long)(ti * 60.0f);
	return soon;
}

-(id) initWithTimeIntervalSinceReferenceDate: (NSTimeInterval)ticks {
	self = [super init];
	if( self ) {
		_ticksSinceStartup = (unsigned long)(ticks * 60.0f);
	}
	return self;
}

-(NSTimeInterval) timeIntervalSinceReferenceDate {
	return ((NSTimeInterval) _ticksSinceStartup) / 60.0f;
}

+(NSTimeInterval) timeIntervalSinceReferenceDate {
	return ((NSTimeInterval) TickCount()) / 60.0f;
}

-(unsigned long) ticksSinceStartup
{
	return _ticksSinceStartup;
}

@end
