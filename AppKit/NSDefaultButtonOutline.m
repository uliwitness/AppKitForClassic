#import "NSDefaultButtonOutline.h"
#include "ToolboxHider.h"
#include <Quickdraw.h>


@implementation NSDefaultButtonOutline

-(void) drawRect: (NSRect)dirtyRect {
	if (NSGetAppearanceVersion() == LONG_MIN) {
		Rect box = QDRectFromNSRect([self bounds]);
		PenSize(3,3);
		FrameRoundRect(&box, 16, 16);
		PenSize(1,1);
	}
}

@end
