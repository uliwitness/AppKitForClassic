#include "NSString.h"


// String class used for strings allocated at runtime.
// Instances of this object are freed when their last reference is released.
@interface NSCString: NSString
{
	char* _bytes;
	unsigned _numBytes;
}

-(id) initWithCString: (const char*)text;
-(id) initWithCharacters: (const char*)text length: (unsigned)len;

@end