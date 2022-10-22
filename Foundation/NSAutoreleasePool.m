#import "NSAutoreleasePool.h"

NSAutoreleasePool* gCurrentPool = nil;

@implementation NSAutoreleasePool

-(id) init
{
	self = [super init];
	
	if( self ) {
		_storage = [[NSMutableArray alloc] init];
	
		_previousPool = gCurrentPool;
		gCurrentPool = self;
	}
	
	return self;
}


-(void) dealloc
{
	gCurrentPool = _previousPool;
	[_storage release];
	
	[super dealloc];
}


-(void) addObject: (NSObject*)object
{
	[_storage addObject: object];
	[object release];
}

@end
