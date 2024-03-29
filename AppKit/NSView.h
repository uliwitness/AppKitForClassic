#import "Foundation.h"
#import "NSGeometry.h"
#import "NSResponder.h"

@class NSWindow;
@class NSColor;
@class NSEvent;
@class NSView;

extern NSView* gCurrentMouseView;

typedef enum _NSAutoresizingMaskOptions {
	NSViewNotSizable = 0,
	NSViewMinXMargin = (1 << 0),
	NSViewWidthSizable = (1 << 1),
	NSViewMaxXMargin = (1 << 2),
	NSViewMinYMargin = (1 << 3),
	NSViewHeightSizable = (1 << 4),
	NSViewMaxYMargin = (1 << 5)
} NSAutoresizingMaskOptions;

@class NSView;

@interface NSView : NSResponder
{
	NSRect _frame;
	NSMutableArray *_subviews;
	NSView *_superview;
	NSAutoresizingMaskOptions _autoresizingMask;
	NSString *_toolTip;
	BOOL _hidden;
}

-(id) initWithFrame: (NSRect)frame;

-(void) drawRect: (NSRect)dirtyRect;

-(NSRect) frame;
-(void) setFrame: (NSRect)box;

-(NSRect) bounds;

-(NSArray*) subviews;
-(void) addSubview: (NSView*)view;

-(NSView*) superview;
-(void) setSuperview: (NSView*)parent; // Private.

-(NSWindow*) window;
-(void) viewDidMoveToWindow: (NSWindow*)wd;

-(void) mouseDown: (NSEvent*)event;
-(void) mouseEntered: (NSEvent*)event;
-(void) mouseExited: (NSEvent*)event;

-(void) setHidden: (BOOL)state;
-(BOOL) isHidden;

-(void) setToolTip: (NSString*)helpText;
-(NSString*) toolTip;

-(NSPoint) convertPoint: (NSPoint)pos fromView: (NSView*)view;
-(NSRect) convertRect: (NSRect)pos toView: (NSView*)view;

-(NSAutoresizingMaskOptions) autoresizingMask;
-(void) setAutoresizingMask: (NSAutoresizingMaskOptions)mask;
-(void) resizeSubviewsWithOldSize: (NSSize)size;
-(void) resizeWithOldSuperviewSize: (NSSize)size;

-(void) setNeedsDisplay: (BOOL)state;
-(void) setNeedsDisplayInRect: (NSRect)box;

-(void) loadSubviewsFromDITL: (short)ditlResID firstResponder: (NSResponder**)outResponder;

// Private:
-(NSColor*) backgroundColor;
-(void) _drawRect: (NSRect)dirtyRect withOffset: (NSPoint)pos;
-(void) _viewDidMoveToWindow: (NSWindow*)wd;
-(BOOL) _mouseDown: (NSEvent*)event;
-(NSView*) _subviewAtPoint: (NSPoint)pos;
-(RgnHandle) _globalRegion; // For mouse enter/exit.
-(void) debugPrintWithIndent: (unsigned)depth;

@end

@interface NSWindowContentView : NSView
{
	NSWindow *_window;
	NSColor *_backgroundColor;
}

-(NSWindow*) window;
-(void) setWindow:(NSWindow*)win;

-(NSColor*) backgroundColor;
-(void) setBackgroundColor: (NSColor*)c;

@end