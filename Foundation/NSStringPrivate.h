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

// String class used for Pascal strings encountered at runtime.
// Instances of this object are freed when their last reference is released.
@interface NSPString: NSString
{
	char _text[257]; // Str255 plus space for a zero-terminator.
}

-(id) initWithStr255: (Str255)text;

@end
