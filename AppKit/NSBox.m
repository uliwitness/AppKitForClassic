#import "NSBox.h"
#import "NSGeometry.h"
#import "NSGraphicsContext.h"
#import "NSColor.h"
#include <Quickdraw.h>
#include <Fonts.h>

#define TITLE_OFFSET 8
#define TITLE_INNER_PADDING 6

@implementation NSBox

-(void) dealloc {
	[_title release];
	_title = nil;
	
	[super dealloc];
}

-(void) drawRect: (NSRect)dirtyRect {
	NSRect boxRect = [self bounds];
	BOOL hasTitle = _title && [_title length] > 0;
	short textHeight = 0;
	FontInfo fontInfo = {0};
	
	if (hasTitle) {
		float titleTopOffset = 0;
		NSRect titleArea;
		TextFont(systemFont);
		TextSize(12);
		TextFace(normal);
		GetFontInfo(&fontInfo);
		
		titleTopOffset = fontInfo.ascent + fontInfo.descent - 1; // -1 to ensure outline matches up with text baseline.
		NSDivideRect(boxRect, &titleArea, &boxRect, titleTopOffset, NSMinYEdge);
		
		[[[self superview] backgroundColor] setFill];
		[NSBezierPath fillRect: titleArea];
	}
		
	[[self backgroundColor] setFill];
	[NSBezierPath fillRect: boxRect];
	[[NSColor grayColor] setStroke];
	[NSBezierPath strokeRect: boxRect];
	
	if (hasTitle) {
		Str255 titleStr = {0};
		NSRect titleTextArea = [self bounds];
		[_title getStr255: titleStr];

		titleTextArea.origin.x += TITLE_OFFSET;
		titleTextArea.size.width = StringWidth(titleStr) + (TITLE_INNER_PADDING * 2);
		titleTextArea.size.height = fontInfo.ascent + fontInfo.descent + fontInfo.leading;
		
		[[self backgroundColor] setStroke];
	 	[NSBezierPath strokeLineFromPoint: NSMakePoint(NSMinX(titleTextArea), NSMinY(boxRect))
	 					toPoint: NSMakePoint(NSMaxX(titleTextArea), NSMinY(boxRect))];
		
		[[NSColor blackColor] setStroke];
		MoveTo(titleTextArea.origin.x + TITLE_INNER_PADDING, NSMaxY(titleTextArea) - fontInfo.leading);
		DrawString(titleStr);
	}
}

-(NSColor*) backgroundColor
{
	if (_fillColor) {
		return _fillColor;
	}
	return [[self superview] backgroundColor];
}

-(NSString*) title
{
	return _title;
}

-(void) setTitle: (NSString*)c
{
	NSString *oldTitle = _title;
	_title = [c retain];
	[oldTitle release];
	[self setNeedsDisplay: YES];
}

-(NSColor*) fillColor
{
	return _fillColor;
}

-(void) setFillColor: (NSColor*)c
{
	NSColor *oldColor = _fillColor;
	_fillColor = [c retain];
	[oldColor release];
	[self setNeedsDisplay: YES];
}

@end
