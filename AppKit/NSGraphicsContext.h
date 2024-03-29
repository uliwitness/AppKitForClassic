#import "Foundation.h"
#import "NSGeometry.h"
#include <Quickdraw.h>

@class NSGraphicsContext;

struct SavedGraphicsState {
	Point _savedOrigin;
	RgnHandle _savedClip;
	RGBColor _foreColor;
	RGBColor _backColor;
	Point _lineWidth;
	NSGraphicsContext *_context;
};

@interface NSGraphicsContext : NSObject
{
	GrafPtr _macPort;
	unsigned _savedStateCount;
	struct SavedGraphicsState* _savedState;
}

+(NSGraphicsContext*) currentContext;
+(void) setCurrentContext: (NSGraphicsContext*)context;

-(id) initWithGraphicsPort: (GrafPtr)port;

-(void) saveGraphicsState;
-(void) restoreGraphicsState;

// Private:
-(GrafPtr) macGraphicsPort;

@end

@class NSBezierPath;

@interface NSBezierPath : NSObject
{
	RgnHandle _macRegion;
}

+(void) strokeRect: (NSRect)box;
+(void) fillRect: (NSRect)box;
+(void) clipRect: (NSRect)box;
+(void) strokeLineFromPoint: (NSPoint)start toPoint: (NSPoint)end;

-(RgnHandle) macRegion;

//-(void) moveToPoint: (NSPoint)pos;
//-(void) lineToPoint: (NSPoint)pos;
//-(void) closePath;

//-(float) lineWidth;
//-(void) setLineWidth: (float)wd;

//-(NSRect) bounds;

//-(void) appendBezierPath: (NSBezierPath*)other;
//-(void) appendBezierPathWithRect: (NSRect)box;
//-(void) appendBezierPathWithOvalInRect: (NSRect)box;
//-(void) appendBezierPathWithRoundedRect: (NSRect)box radius: (float)rd;

//-(void) stroke;
//-(void) fill;

//-(BOOL) containsPoint: (NSPoint)pos;

@end