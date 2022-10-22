#include "Runtime.h"
#include <Types.h>

typedef struct _NSRange {
	int location;
	int length;
} NSRange;

static NSRange NSMakeRange(int location, int length) {
	NSRange range = { 0, 0 };
	range.location = location;
	range.length = length;
	return range;
}

static int NSMaxRange(NSRange range) {
	return range.location + range.length;
}

// ** NSSTRING IS A CLASS CLUSTER **
// This means you will never get objects of type NSString, only of
// private subclasses that implement the same methods.
//
// How this works is: We return a singleton object from alloc in NSString,
// and when you call one of the init methods on it, we know what object
// you REALLY want, and call alloc/init on that and return a different
// object.
@interface NSString : NSObject

+(id) alloc;
-(id) initWithCString: (const char*)text;
-(id) initWithCharacters: (const char*)text length: (unsigned)len;
-(id) initWithStr255: (Str255)text;

- (unsigned) length;
- (const char *)cString;

- (NSRange) rangeOfString: (NSString*)pattern;
- (NSString*) substringWithRange: (NSRange)range;
- (NSString*) substringFromIndex: (int)startIndex;
- (NSString*) substringToIndex: (int)length;

@end

// *** DO NOT USE THE FOLLOWING CLASS YOURSELF ***
// The class CodeWarrior creates for constant string literals in the executable.
// This class does nothing in response to reference counting (as the literals
// are in a read-only data section of the executable and not on the heap).
// WARNING! MWObjC expects this ivar layout: isa, bytes, numBytes.
// You mustn't change it! That's why we're doing a magic thing re-using the isa
// pointer to store both refCount and an index into our class table, so the
// instance size matches what CodeWarrior expects.
// Also, you must include this header or MWObjC will be unable to create string
// literals in code.

@interface NSConstantString : NSString
{
	char			*_bytes;
	unsigned long	_numBytes;
}

- (unsigned) length;
- (const char *)cString;

@end

extern void* _NSConstantStringClassReference;
