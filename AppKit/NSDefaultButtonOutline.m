#import "NSDefaultButtonOutline.h"
#include <Quickdraw.h>
#include <Gestalt.h>


@implementation NSDefaultButtonOutline

-(void) drawRect: (NSRect)dirtyRect {
	static long haveAppearance = LONG_MAX;
	if (haveAppearance == LONG_MAX) {
		if (Gestalt(gestaltAppearanceAttr, &haveAppearance) != noErr) {
			haveAppearance = LONG_MIN;
		}
	}

	if (haveAppearance == LONG_MIN) {
		Rect box = QDRectFromNSRect([self bounds]);
		PenSize(3,3);
		FrameRoundRect(&box, 16, 16);
		PenSize(1,1);
	}
}

@end
