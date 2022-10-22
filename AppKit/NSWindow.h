#import "Foundation.h"
#import "NSGeometry.h"
#import "NSResponder.h"
#include <MacWindows.h>

@class NSEvent;
@class NSView;
@class NSWindowContentView;
@class NSColor;

@class NSWindow;

@interface NSWindow : NSResponder
{
	BOOL _hasWindow;
	CWindowRecord _macWindow;
	NSString *_title;
	NSWindowContentView *_contentView;
	NSResponder* _firstResponder;
}

-(id) initWithFrame: (NSRect)box title: (NSString*)title;
-(id) initWithDLOG: (short)dlogResID;

-(NSColor*) backgroundColor;
-(void) setBackgroundColor: (NSColor*)c;

-(void) performClose: (id)sender;

-(void) mouseDown: (NSEvent*)event;
-(void) mouseUp: (NSEvent*)event;

-(NSPoint) convertPoint: (NSPoint)pos fromWindow: (NSWindow*)otherWin;

-(void) makeKeyAndOrderFront: (id)sender;
-(void) setSize: (NSSize)newSize;

-(NSView*) contentView;

-(BOOL) makeFirstResponder: (NSResponder*)responder;
-(NSResponder*) firstResponder;

// Private:
-(GrafPtr) macGraphicsPort;
-(void) draw;
-(void) activate;
-(void) deactivate;

+(NSWindow*)windowFromMacWindow: (WindowPtr)window;

@end