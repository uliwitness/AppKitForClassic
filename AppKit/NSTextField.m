#import "NSTextField.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSMenuItem.h"
#include <string.h>

@implementation NSTextField

-(void) dealloc
{
	if( _macTextField ) {
		TEDispose( _macTextField );
	}
	[_stringValue release];
	
	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return _bezeled ? [NSColor whiteColor] : [[self window] backgroundColor];
}

-(void) mouseDown: (NSEvent*)event
{
	Point clickPos = QDPointFromNSPoint( [event locationInWindow] );
	Rect box;
	GrafPtr oldPort;
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	
	if (_bezeled) {
		TEActivate( _macTextField );
		TEClick( clickPos, [event modifierFlags] & NSEventModifierFlagShift, _macTextField );
	}
	
	SetPort( oldPort );
	
	if (_bezeled) {
		[[self window] makeFirstResponder: self];
	}
}

-(void) mouseUp: (NSEvent*)event
{
}

-(void) drawRect: (NSRect)dirtyRect
{
	GrafPtr oldPort;
	Rect outerBox = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	Rect box = outerBox;
	InsetRect( &box, 3, 3 );
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	SetOrigin( 0, 0 );
	ForeColor(blackColor);
	[[self backgroundColor] setFill];
	TEUpdate( &box, _macTextField );
	
	if (_bezeled) {
		FrameRect( &outerBox );
	}
		
	SetPort( oldPort );
}

-(void) viewDidMoveToWindow: (NSWindow*)wd
{
	if( !_macTextField ) {
		Rect scrollableBox;
		GrafPtr oldPort;
		TextStyle styleRec = {0};
		unsigned len = [_stringValue length];
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		if (_bezeled) {
			InsetRect( &box, 3, 3 );
		}
		scrollableBox = box;
		if (_bezeled) {
			//scrollableBox.right = 10000;
		}
		
		GetPort( &oldPort );
		SetPort( [[self window] macGraphicsPort] );
		
		_macTextField = TENew( &scrollableBox, &box );
		(**_macTextField).txFont = 0;
		(**_macTextField).txFace = normal;
		(**_macTextField).txSize = 12;
		TEFeatureFlag(teFUseWhiteBackground, teBitClear, _macTextField);
		TEFeatureFlag(teFAutoScroll, teBitSet, _macTextField);
		if (_bezeled) {
			TEFeatureFlag(teFOutlineHilite, teBitSet, _macTextField);
		}
		styleRec.tsFont = systemFont;
		styleRec.tsFace = normal;
		styleRec.tsSize = 12;
		
		TESetStyle(doFont, &styleRec, false, _macTextField);
		TESetText( [_stringValue cString], len, _macTextField );
		TECalText( _macTextField );
		
		SetPort( oldPort );
	}
	if( wd == nil ) {
		[_caretTimer invalidate];
		_caretTimer = nil;
	} 
}

-(NSString*) stringValue
{
	return _stringValue;
}

-(void) setStringValue: (NSString*)str
{
	NSString *oldString = _stringValue;
	_stringValue = [str retain];
	[oldString release];
	
	if( _macTextField ) {
		Rect box;
		unsigned len;
		GrafPtr oldPort;
		TextStyle styleRec = {0};
		GetPort( &oldPort );
		SetPort( [[self window] macGraphicsPort] );
		
		len = [_stringValue length];
		TESetText( [_stringValue cString], len, _macTextField );
		styleRec.tsFont = systemFont;
		styleRec.tsFace = normal;
		styleRec.tsSize = 12;
		
		TESetStyle(doFont, &styleRec, false, _macTextField);
		TECalText( _macTextField );
		box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		if (_bezeled) {
			InsetRect( &box, 3, 3 );
		}
		SetOrigin( 0, 0 );
		TEUpdate( &box, _macTextField );
		
		SetPort( oldPort );
	}
}

-(void) setFrame: (NSRect)newFrame
{
	[super setFrame: newFrame];
	
	if( _macTextField ) {
		Rect box;
		GrafPtr oldPort;
		GetPort( &oldPort );
		SetPort( [[self window] macGraphicsPort] );
		SetOrigin( 0, 0 );
		
		box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		if (_bezeled) {
			InsetRect( &box, 3, 3 );
		}
		(**_macTextField).destRect = box;
		(**_macTextField).viewRect = box;
		if (_bezeled) {
			//(**_macTextField).viewRect.right = 10000;
		}
		TECalText( _macTextField );
		InvalRect( &box );
		
		SetPort( oldPort );
	}
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

-(BOOL) acceptsFirstResponder
{
	return _bezeled;
}

-(BOOL) becomeFirstResponder
{
	if (_macTextField && _bezeled) {
		GrafPtr oldPort;
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		GetPort( &oldPort );
		SetPort( [[self window] macGraphicsPort] );
		TEFeatureFlag(teFOutlineHilite, teBitSet, _macTextField);
		TEActivate( _macTextField );
		TESetSelect( 0, (**_macTextField).teLength, _macTextField );
		InvalRect( &box );
		SetPort( oldPort );
		
		if( !_caretTimer ) {
			_caretTimer = [NSTimer scheduledTimerWithTimeInterval: ((float)GetCaretTime()) / 60.0f target: self selector: @selector(flashCaret:)
									userInfo: nil repeats: YES];
		}
	}
	return YES;
}

-(BOOL) resignFirstResponder
{
	[_caretTimer invalidate];
	_caretTimer = nil;
	if (_macTextField) {
		GrafPtr oldPort;
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		GetPort( &oldPort );
		SetPort( [[self window] macGraphicsPort] );
		TEDeactivate( _macTextField );
		TEFeatureFlag(teFOutlineHilite, teBitClear, _macTextField);
		InvalRect( &box );
		SetPort( oldPort );
	}
	return YES;
}

-(void) flashCaret: (NSTimer*)sender
{
	GrafPtr oldPort;
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	TEIdle(_macTextField);
	SetPort( oldPort );
}

-(void) keyDown: (NSEvent*)event
{
	if( ([event modifierFlags] & cmdKey) == 0 ) {
		char keyPressed = [[event characters] cString][0];
		BOOL typeKey = YES;
		GrafPtr oldPort;
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		GetPort( &oldPort );
		SetPort( [[self window] macGraphicsPort] );
		if( [event modifierFlags] & shiftKey ) {
			switch( keyPressed ) {
				case kLeftArrowCharCode: {
					long newStart = (**_macTextField).selStart - 1;
					if (newStart >= 0) {
						TESetSelect(newStart, (**_macTextField).selEnd, _macTextField);
					}
					typeKey = NO;
					break;
				}
				case kRightArrowCharCode: {
					long newEnd = (**_macTextField).selEnd + 1;
					if (newEnd <= (**_macTextField).teLength) {
						TESetSelect((**_macTextField).selStart, newEnd, _macTextField);
					}
					typeKey = NO;
					break;
				}
			}
		}
		
		if( typeKey ) {
			TEKey( keyPressed, _macTextField );
		}
		SetPort( oldPort );
	}
}

-(void) cut: (id)sender
{
	GrafPtr oldPort;
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	TECut(_macTextField);
	SetPort( oldPort );
}

-(void) copy: (id)sender
{
	GrafPtr oldPort;
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	TECopy(_macTextField);
	SetPort( oldPort );
}

-(void) paste: (id)sender
{
	GrafPtr oldPort;
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	TEPaste(_macTextField);
	SetPort( oldPort );
}

-(void) delete: (id)sender
{
	GrafPtr oldPort;
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	TEDelete(_macTextField);
	SetPort( oldPort );
}

-(BOOL) validateMenuItem: (NSMenuItem*)item
{
	SEL action = [item action];
	if( strcmp((const char*)action, (const char*)@selector(cut:)) == 0
		|| strcmp((const char*)action, (const char*)@selector(copy:)) == 0
		|| strcmp((const char*)action, (const char*)@selector(delete:)) == 0 ) {
		return _macTextField && (**_macTextField).selStart < (**_macTextField).selEnd;
	} else if(strcmp((const char*)action, (const char*)@selector(paste:)) == 0) {
		return YES;
	}
	return NO;
}

-(void) mouseMoved: (NSEvent*)event
{
	GrafPtr oldPort;
	Point pos, windowPos = { 0, 0 };
	Rect box;
	GetMouse(&pos);
	
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	LocalToGlobal( &windowPos );
	SetPort( oldPort );
	
	box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	box.left += windowPos.h;
	box.right += windowPos.h;
	box.top += windowPos.v;
	box.bottom += windowPos.v;
	
	if( PtInRect(pos, &box) ) {
		CursHandle textCursor = GetCursor(iBeamCursor);
		SetCursor(*textCursor);
	} else {
		SetCursor(&qd.arrow);
	}
}

-(void) setBezeled: (BOOL)state {
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	if (_bezeled) {
		InsetRect( &box, 3, 3 );
	}
	(**_macTextField).destRect = box;
	(**_macTextField).viewRect = box;
	if (_bezeled) {
		//(**_macTextField).viewRect.right = 10000;
	}

	_bezeled = state;
}


@end