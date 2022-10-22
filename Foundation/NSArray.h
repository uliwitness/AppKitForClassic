#import "Foundation.h"
#include <limits.h>

#define NSNotFound USHRT_MAX

@class NSMutableArray;

@interface NSMutableArray : NSObject
{
	unsigned _count;
	id *_storage;
}

-(unsigned) count;
-(void) addObject: (id)obj;
-(void) removeObjectAtIndex: (unsigned)idx;
-(void) removeObjectIdenticalTo: (id)obj;
-(id) objectAtIndex: (unsigned)idx; // returns NIL if index out of range.
-(unsigned) indexOfObjectIdenticalTo: (id)obj;

@end
