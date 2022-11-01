#include "Runtime.h"
#include <Types.h>
#include <stdarg.h>

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
-(id) initWithFormat: (NSString*)fmtObj, ...;
-(id) initWithFormat: (NSString*)fmtObj arguments: (va_list)ap;

+(id) stringWithCString: (const char*)text;
+(id) stringWithCharacters: (const char*)text length: (unsigned)len;
+(id) stringWithStr255: (Str255)text;
+(id) stringWithFormat: (NSString*)fmtObj, ...;

- (unsigned) length;
- (const char *)cString;
- (void) getStr255: (Str255)outString;

-(BOOL) isEqualToString: (NSString*)str;

- (NSRange) rangeOfString: (NSString*)pattern;
- (NSString*) substringWithRange: (NSRange)range;
- (NSString*) substringFromIndex: (int)startIndex;
- (NSString*) substringToIndex: (int)length;

-(id) copy; 		// Always gives an immutable object (even when called on NSMutableString).
-(id) mutableCopy;	// Always gives a new NSMutableString.

@end

// This is the only subclass of NSString you are supposed to create yourself.
@interface NSMutableString : NSString
{
	char *_cString;
	unsigned _length;
}

-(void) replaceCharactersInRange: (NSRange)range withString: (NSString*)str;

// All implemented via -replaceCharactersInRange:withString:
-(void) appendString: (NSString*)strObj;
-(void) insertString: (NSString*)strObj atIndex: (unsigned)destIdx;
-(void) deleteCharactersInRange: (NSRange)delRange;
-(void) setString: (NSString*)strObj;

-(void) appendFormat: (NSString*)fmtObj, ...;
-(void) appendFormat: (NSString*)fmtObj arguments: (va_list)ap; // Nonstandard central format bottleneck.

// Nonstandard, used by -replaceCharactersInRange:withString:
-(void) replaceCharactersInRange: (NSRange)range withCharacters: (const char*)bytes length: (unsigned)len;

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
