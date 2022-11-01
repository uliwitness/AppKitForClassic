#import "NSMiniRuntime.h"

typedef float NSTimeInterval;

@interface NSDate : NSObject
{
	unsigned long _ticksSinceStartup;
}

+(id) currentDate;

+(id) dateWithTimeIntervalSinceNow: (NSTimeInterval)ti;

-(id) initWithTimeIntervalSinceReferenceDate: (NSTimeInterval)ticks;

-(NSTimeInterval) timeIntervalSinceReferenceDate;

+(NSTimeInterval) timeIntervalSinceReferenceDate;

// private:
-(unsigned long) ticksSinceStartup;

@end
