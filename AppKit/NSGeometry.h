#import "Foundation.h"
#include <Quickdraw.h>

typedef struct _NSPoint {
	float x;
	float y;
} NSPoint;

typedef struct _NSSize {
	float width;
	float height;
} NSSize;

typedef struct _NSRect {
	NSPoint origin;
	NSSize size;
} NSRect;

typedef enum _NSRectEdge {
	NSMinXEdge,
	NSMinYEdge,
	NSMaxXEdge,
	NSMaxYEdge
} NSRectEdge;

NSRect NSMakeRect(float x, float y, float width, float height);
NSPoint NSMakePoint(float x, float y);
NSSize NSMakeSize(float w, float h);

float NSMaxX(NSRect box);
float NSMinX(NSRect box);
float NSMaxY(NSRect box);
float NSMinY(NSRect box);
float NSMidX(NSRect box);
float NSMidY(NSRect box);

NSRect NSInsetRect(float x, float y, NSRect box);
void NSDivideRect(NSRect inRect, NSRect *slice, NSRect *remainder, float amount, NSRectEdge edge);

BOOL NSPointInRect(NSPoint pos, NSRect box);

Rect QDRectFromNSRect(NSRect box);
NSRect NSRectFromQDRect(Rect box);

Point QDPointFromNSPoint(NSPoint pos);
NSPoint NSPointFromQDPoint(Point pos);


