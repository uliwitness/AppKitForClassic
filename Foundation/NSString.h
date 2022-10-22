#include "Runtime.h"

// ** NSSTRING IS A CLASS CLUSTER **
// This means you will never get objects of type NSString, only of
// private subclasses that implement the same methods.
//
// How this works is: We return a singleton object from alloc in NSString,
// and when you call one of the init methods on it, we know what object
// you REALLY want, and call alloc/init on that and return a different
// object.

// For implementation reasons (string literals/NSConstantString),
// NSString the base class is not an NSObject. However, most of the
// subclasses that are returned when you create an NSString are
// reference-counted. All of them can basically be treated like
// NSObjects, even if they aren't.
@interface NSString : NSObject

+alloc;
-(id) initWithCString: (const char*)text;
-(id) initWithCharacters: (const char*)text length: (unsigned)len;

- (unsigned) length;
- (const char *)cString;

@end

// *** DO NOT USE THE FOLLOWING CLASS YOURSELF ***
// The class CodeWarrior creates for constant string literals in the executable.
// This class does nothing in response to reference counting (as the literals
// are in a read-only data section of the executable and not on the heap).
// WARNING! MWObjC expects this ivar layout: isa, bytes, numBytes.
// You mustn't change it! Also, you must include this header or MWObjC
// will be unable to create string literals in code.
@interface NSConstantString : NSString
{
	char			*_bytes;
	unsigned long	_numBytes;
}

- (unsigned) length;
- (const char *)cString;

@end

extern void* _NSConstantStringClassReference;
