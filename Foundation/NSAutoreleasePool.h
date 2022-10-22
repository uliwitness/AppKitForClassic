#import "Foundation.h"
#import "NSArray.h"

@class NSAutoreleasePool;

@interface NSAutoreleasePool : NSObject
{
	id _previousPool;
	id _storage;
}

-(void) addObject: (NSObject*)object;

@end

extern NSAutoreleasePool* gCurrentPool;