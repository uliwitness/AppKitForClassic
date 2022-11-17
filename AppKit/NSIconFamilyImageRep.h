#import "NSImage.h"
#include <Quickdraw.h>

@interface NSIconFamilyImageRep : NSImageRep
{
	short _resID;
	NSSize _size;
}

-(id) initWithIconFamilyResource: (short)resID;

-(NSSize) size;

-(void) drawInRect: (NSRect)box;

@end
