#import "NSGeometry.h"

NSRect NSMakeRect(float x, float y, float width, float height)
{
	NSRect result;
	result.origin.x = x;
	result.origin.y = y;
	result.size.width = width;
	result.size.height = height;
	return result;
}


NSPoint NSMakePoint(float x, float y)
{
	NSPoint result;
	result.x = x;
	result.y = y;
	return result;
}


NSSize NSMakeSize(float w, float h)
{
	NSSize result;
	result.width = w;
	result.height= h;
	return result;
}


float NSMaxX(NSRect box)
{
	return box.origin.x + box.size.width;
}

float NSMinX(NSRect box)
{
	return box.origin.x;
}

float NSMaxY(NSRect box)
{
	return box.origin.y + box.size.height;
}

float NSMinY(NSRect box)
{
	return box.origin.y;
}

float NSMidX(NSRect box)
{
	return box.origin.x + (box.size.width / 2.0);
}

float NSMidY(NSRect box)
{
	return box.origin.y + (box.size.height / 2.0);
}


NSRect NSInsetRect(float x, float y, NSRect box) {
	box.size.width -= 2.0 * x;
	box.size.height -= 2.0 * y;
	box.origin.x += x;
	box.origin.y += y;
	return box;
}


Rect QDRectFromNSRect(NSRect box) {
	Rect result;
	
	SetRect(&result, (short)box.origin.x, (short)box.origin.y,
			(short)box.origin.x + box.size.width, (short)box.origin.y + box.size.height);
	
	return result;
}

NSRect NSRectFromQDRect(Rect box) {
	NSRect result = NSMakeRect( (float)box.left, (float)box.top,
								(float)box.right - box.left, (float)box.bottom - box.top);
	
	return result;
}


Point QDPointFromNSPoint(NSPoint pos) {
	Point result;
	
	result.h = (short)pos.x;
	result.v = (short)pos.y;
	
	return result;
}

NSPoint NSPointFromQDPoint(Point pos) {
	NSPoint result = NSMakePoint( (float)pos.h, (float)pos.v);
	
	return result;
}
