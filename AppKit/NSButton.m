#import "NSButton.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSCursor.h"
#import "NSApplication.h"
//#include <ControlDefinitions.h>
#define pushButProc 0
#define inButton 10

@implementation NSButton

-(void) dealloc
{
	if( _macControl ) {
		DisposeControl(_macControl);
	}
	
	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return [[self window] backgroundColor];
}

-(void) mouseDown: (NSEvent*)event
{
	Rect box;
	GrafPtr oldPort;
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	MoveControl( _macControl, box.left, box.top );
	SizeControl( _macControl, box.right - box.left, box.bottom - box.top );
	if( inButton == TrackControl( _macControl, [event macEvent].where, NULL ) ) {
		[[NSApplication sharedApplication] sendAction: _action to: _target from: self];
	}
	SetPort( oldPort );
}

-(void) mouseUp: (NSEvent*)event
{
}

-(void) mouseEntered: (NSEvent*)event {
	[super mouseEntered: event];
	[[NSCursor pointingHandCursor] set];
}

-(void) drawRect: (NSRect)dirtyRect
{
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	SetOrigin( 0, 0 );
	MoveControl( _macControl, box.left, box.top );
	SizeControl( _macControl, box.right - box.left, box.bottom - box.top );
	Draw1Control( _macControl );
}

-(void) viewDidMoveToWindow: (NSWindow*)wd
{
	if( !_macControl ) {
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		_macControl = newcontrol( [wd macGraphicsPort],
									&box,
									[_title cString],
									true,
									0,
									0,
									0,
									pushButProc,
									(long)self );
	}
}

-(NSString*) title
{
	return _title;
}

-(void) setTitle: (NSString*)str
{
	NSString *oldString = _title;
	_title = [str retain];
	[oldString release];
}

-(void) setTarget: (NSObject*)target
{
	_target = target;
}

-(NSObject*) target
{
	return _target;
}

-(void) setAction: (SEL)act
{
	_action = act;
}

-(SEL) action
{
	return _action;
}

@end