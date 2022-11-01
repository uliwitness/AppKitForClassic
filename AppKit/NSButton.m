#import "NSButton.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSCursor.h"
#import "NSApplication.h"
#include "ToolboxHider.h"

@implementation NSButton

-(void) dealloc
{
	if( _macControl ) {
		DisposeControl(_macControl);
	}
	[_shortcut release];
	
	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return [[self superview] backgroundColor];
}

-(void) mouseDown: (NSEvent*)event
{
	short part;
	Rect box;
	GrafPtr oldPort;
	GetPort( &oldPort );
	SetPort( [[self window] macGraphicsPort] );
	[[self backgroundColor] setFill];
	box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	MoveControl( _macControl, box.left, box.top );
	SizeControl( _macControl, box.right - box.left, box.bottom - box.top );
	part = TrackControl(_macControl, [event macEvent].where, NULL);
	if (part == inButton || part == inCheckBox) {
		[self setNextState];
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

-(void) setNextState {
	NSControlState state = [self state];
	
	if (_type == NSButtonTypeRadio) {
		[self setState: NSOnState];
	} else if (state == NSOnState) {
		[self setState: NSOffState];
	} else if (state == NSOffState) {
		[self setState: NSOnState];
	}
}

-(void) drawRect: (NSRect)dirtyRect
{
	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
	[[self backgroundColor] setFill];
	SetOrigin( 0, 0 );
	MoveControl( _macControl, box.left, box.top );
	SizeControl( _macControl, box.right - box.left, box.bottom - box.top );
	Draw1Control( _macControl );
}

-(void) viewDidMoveToWindow: (NSWindow*)wd
{
	if (!_macControl) {
		Rect box;
		Boolean isDefault = [_shortcut isEqualToString: @"\r"];
		short cdef = pushButProc;
		switch (_type) {
			case NSButtonTypeMomentaryPushIn:
				cdef = pushButProc;
				break;
			case NSButtonTypeSwitch:
				cdef = checkBoxProc;
				break;
			case NSButtonTypeRadio:
				cdef = radioButProc;
				break;
		}
		
		box = QDRectFromNSRect([self convertRect: [self bounds] toView: nil]);
		_macControl = newcontrol( [wd macGraphicsPort],
									&box,
									[_title cString],
									true,
									0,
									0,
									1,
									cdef,
									(long)self);
		if (NSGetAppearanceVersion() != LONG_MIN && cdef == pushButProc) {
			SetControlData(_macControl, kControlEntireControl, kControlPushButtonDefaultTag,
							sizeof(Boolean), &isDefault);
		}
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

-(void) setButtonType: (NSButtonType)type {
	_type = type;
	
	if ([self window] != nil) {
		if (_macControl) {
			DisposeControl(_macControl);
		}
		_macControl = NULL;
		[self viewDidMoveToWindow: [self window]];
		[self setNeedsDisplay: YES];
	}
}

-(void) setState: (NSControlState)state {
	if (_type == NSButtonTypeSwitch || _type == NSButtonTypeRadio) {
		if (state == NSOnState) {
			SetControlValue(_macControl, 1);
		} else if (state == NSOffState) {
			SetControlValue(_macControl, 0);
		}
	}
	[self setNeedsDisplay: YES];
}

-(NSControlState) state {
	if (_type == NSButtonTypeSwitch || _type == NSButtonTypeRadio) {
		SInt16 value = GetControlValue(_macControl);
		if (value == 1) {
			return NSOnState;
		} else if (value == 0) {
			return NSOffState;
		}
		
		return NSOffState;
	}
	
	return NSOffState;
}

-(void) setKeyEquivalent: (NSString*)shortcut {
	NSString *oldVal = _shortcut;
	_shortcut = [shortcut retain];
	[oldVal release];
	
	if ([self window] != nil && NSGetAppearanceVersion() != LONG_MIN) {
		Boolean isDefault = [_shortcut isEqualToString: @"\r"];
		SetControlData(_macControl, kControlEntireControl, kControlPushButtonDefaultTag,
						sizeof(Boolean), &isDefault);
		[self setNeedsDisplay: YES];
	}
}

@end