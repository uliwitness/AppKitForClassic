#import "NSMiniRuntime.h"
#include <limits.h>

#define NSNotFound USHRT_MAX

@class NSEnumerator;

@interface NSArray : NSObject
{
	unsigned _count;
	id *_storage;
}

+(id) arrayWithObjects: (id)firstObject, ...;

-(id) initWithObjects: (id)firstObject, ...;
-(id) initWithObjects: (id*)storage count: (unsigned)count;

-(unsigned) count;
-(id) objectAtIndex: (unsigned)idx; // returns NIL if index out of range.
-(unsigned) indexOfObjectIdenticalTo: (id)obj;
-(unsigned) indexOfObject: (id)obj;

-(NSEnumerator*) objectEnumerator;

-(NSString*) description;
-(NSString*) debugDescription;

-(id) copy;
-(id) mutableCopy;

@end

@interface NSMutableArray : NSArray

-(void) addObject: (id)obj;
-(void) removeObjectAtIndex: (unsigned)idx;
-(void) removeObjectIdenticalTo: (id)obj;

-(void) sortUsingSelector: (SEL)comparator;

-(id) copy;

@end
