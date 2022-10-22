#import "NSView.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSGraphicsContext.h"
#import "ToolboxHider.h"
#include <Quickdraw.h>


@implementation NSView

-(id) initWithFrame: (NSRect)frame
{
	self = [super init];
	if( self ) {
		_frame = frame;
		_subviews = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void) dealloc
{
	[_subviews release];
	
	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return [NSColor orangeColor];
}

-(void) drawRect: (NSRect)dirtyRect
{
	//Rect box = QDRectFromNSRect( [self bounds] );
	//FrameRect( &box );
}

-(void) _drawRect: (NSRect)dirtyRect withOffset: (NSPoint)pos
{
	GrafPtr currentPort = NULL;
	int count, x;
	
	GetPort( &currentPort );
	SetOrigin( -pos.x, -pos.y );
	
	[[self backgroundColor] set];
	[NSBezierPath fillRect: [self bounds]];
	[[NSColor blackColor] set];
	
	[self drawRect: dirtyRect];
	SetOrigin( 0, 0 );
	
	count = [_subviews count];
	for( x = 0; x < count; ++x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		NSPoint offset = NSMakePoint(pos.x + [currentSubview frame].origin.x, pos.y + [currentSubview frame].origin.y);
		[currentSubview _drawRect: dirtyRect withOffset: offset];
	}
}

-(NSRect) frame
{
	return _frame;
}


-(void) setFrame: (NSRect)box
{
	_frame = box;
}

-(NSRect) bounds
{
	return NSMakeRect( 0, 0, _frame.size.width, _frame.size.height );
}

-(NSMutableArray*) subviews
{
	return _subviews;
}

-(void) addSubview: (NSView*)view
{
	[_subviews addObject: view];
	[view setSuperview: self];
}

-(NSView*) superview
{
	return _superview;
}

-(void) setSuperview: (NSView*)parent
{
	NSWindow * oldWin = [_superview window];
	NSWindow * newWin = [parent window];
	
	_superview = parent;
	[self setNextResponder: parent];
	
	if( oldWin != newWin ) {
		[self _viewDidMoveToWindow: newWin];
	}
}

-(NSWindow*) window
{
	return [_superview window];
}

-(void) viewDidMoveToWindow: (NSWindow*)wd
{

}

-(void) _viewDidMoveToWindow: (NSWindow*)wd
{
	int x, count = [_subviews count];
	
	[self viewDidMoveToWindow: wd];
	
	if( _superview == nil ) {
		[self setNextResponder: wd];
	}

	for( x = 0; x < count; ++x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		[currentSubview _viewDidMoveToWindow: wd];
	}
}

-(NSPoint) convertPoint: (NSPoint)pos fromView: (NSView*)view
{
	NSPoint result = pos;
	if( _superview == view ) {
		result.x -= [self frame].origin.x;
		result.y -= [self frame].origin.y;
	} else {
		NSView *currView = self;
		if( view == nil ) {
			view = [[self window] contentView];
		}
		while( currView != nil && currView != view ) {
			result.x -= [currView frame].origin.x;
			result.y -= [currView frame].origin.y;
			
			currView = [currView superview];
		}
	}
	
	return result;
}

-(NSRect) convertRect: (NSRect)box toView: (NSView*)view
{
	NSRect result = box;
	if( _superview == view ) {
		result.origin.x += [self frame].origin.x;
		result.origin.y += [self frame].origin.y;
	} else {
		NSView *currView = self;
		if( view == nil ) {
			view = [[self window] contentView];
		}
		while( currView != nil && currView != view ) {
			result.origin.x += [currView frame].origin.x;
			result.origin.y += [currView frame].origin.y;
			
			currView = [currView superview];
		}
	}
	
	return result;
}


-(void) resizeSubviewsWithOldSize: (NSSize)size
{
	int x, count = [_subviews count];
	
	for( x = 0; x < count; ++x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		[currentSubview resizeWithOldSuperviewSize: size];
	}
}


-(void) resizeWithOldSuperviewSize: (NSSize)size
{
	NSRect myFrame = [self frame];
	NSRect newFrame = myFrame;
	float leftDistance = NSMinX( myFrame );
	float topDistance = NSMinY( myFrame );
	float rightDistance = size.width -NSMaxX( myFrame );
	float bottomDistance = size.height -NSMaxY( myFrame );
	
	if( _autoresizingMask & NSViewMinXMargin ) {
		newFrame.origin.x = leftDistance;
		if( _autoresizingMask & NSViewMaxXMargin ) {
			if( _autoresizingMask & NSViewWidthSizable ) {
				newFrame.size.width = [[self superview] bounds].size.width - leftDistance - rightDistance;
			} else {
				newFrame.origin.x = ([[self superview] bounds].size.width -newFrame.size.width) / 2.0;
			}
		}
	} else if( _autoresizingMask & NSViewMaxXMargin ) {
		newFrame.origin.x = ([[self superview] bounds].size.width -newFrame.size.width -rightDistance);
	}
	
	if( _autoresizingMask & NSViewMinYMargin ) {
		newFrame.origin.y = topDistance;
		if( _autoresizingMask & NSViewMaxYMargin ) {
			if( _autoresizingMask & NSViewHeightSizable ) {
				newFrame.size.height = [[self superview] bounds].size.height - topDistance - bottomDistance;
			} else {
				newFrame.origin.y = ([[self superview] bounds].size.height -newFrame.size.height) / 2.0;
			}
		}
	} else if( _autoresizingMask & NSViewMaxYMargin ) {
		newFrame.origin.y = ([[self superview] bounds].size.height -newFrame.size.height -bottomDistance);
	}
	
	[self setFrame: newFrame];
	
	[self resizeSubviewsWithOldSize: myFrame.size];
}


-(NSAutoresizingMaskOptions) autoresizingMask
{
	return _autoresizingMask;
}


-(void) setAutoresizingMask: (NSAutoresizingMaskOptions)mask
{
	_autoresizingMask = mask;
}


-(void) mouseDown: (NSEvent*)event
{
	NSBeep();
}

-(BOOL) _mouseDown: (NSEvent*)event
{
	int x, count = [_subviews count];
	NSPoint pos;
	NSRect box;

	for( x = (count - 1); x >= 0; --x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		if( [currentSubview _mouseDown: event] ) {
			return YES;
		}
	}
	
	pos = [self convertPoint: [event locationInWindow] fromView: nil];
	box = [self bounds];
	
	if( (pos.x >= box.origin.x) && (pos.y >= box.origin.y)
		&& (pos.x <= (box.origin.x + box.size.width))
		&& (pos.y <= (box.origin.y + box.size.height)) ) {
		[self mouseDown: event];
		return YES;
	}
	
	return NO;
}

@end

@implementation NSWindowContentView

-(id) initWithFrame: (NSRect)box
{
	self = [super initWithFrame: box];
	if( self ) {
		_backgroundColor = [[NSColor pinkColor] retain];
	}
	
	return self;
}

-(void) dealloc
{
	[_backgroundColor release];
	
	[super dealloc];
}

-(NSWindow*) window
{
	return _window;
}

-(void) setWindow:(NSWindow*)win
{
	if( win != _window ) {
		_window = win;
		[self setNextResponder: win];
		
		[self _viewDidMoveToWindow: win];
	}
}

-(NSColor*) backgroundColor
{
	return _backgroundColor;
}

-(void) setBackgroundColor: (NSColor*)c
{
	NSColor *oldColor = _backgroundColor;
	_backgroundColor = [c retain];
	[oldColor release];
}

@end