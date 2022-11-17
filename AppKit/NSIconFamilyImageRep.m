#import "NSIconFamilyImageRep.h"
#include <Resources.h>
#include <Icons.h>

@implementation NSIconFamilyImageRep

-(id) initWithIconFamilyResource: (short)resID {
	self = [super init];
	if (self) {
		_resID = resID;
		if (GetResource('ICN#', resID) != NULL
			|| GetResource('icl4', resID) != NULL
			|| GetResource('icl8', resID) != NULL) {
			_size = NSMakeSize(32, 32);
		} else {
			_size = NSMakeSize(16, 16);
		}
	}
	return self;
}

-(void) dealloc {
	[super dealloc];
}

-(NSSize) size {
	return _size;
}

-(void) drawInRect: (NSRect)box {
	Rect qdBox = QDRectFromNSRect(box);
	PlotIconID(&qdBox, atAbsoluteCenter, ttNone, _resID);
}

@end