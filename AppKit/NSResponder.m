#import "NSResponder.h"
#import "ToolboxHider.h"

@implementation NSResponder : NSObject

-(NSResponder*) nextResponder {
	return _nextResponder;
}

-(void) setNextResponder: (NSResponder*)next {
	_nextResponder = next;
}

-(void) mouseDown: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder mouseDown: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}


-(void) mouseUp: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder mouseUp: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}


-(void) keyDown: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder keyDown: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}

-(void) keyUp: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder keyUp: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}

-(void) mouseEntered: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder mouseEntered: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}

-(void) mouseExited: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder mouseExited: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}

-(void) idle: (NSEvent*)event {
	if( _nextResponder ) {
		[_nextResponder idle: event];
		return;
	}
	
	[self noResponderFor: _cmd];
}

-(void) noResponderFor: (SEL)eventSelector {
	if( eventSelector == @selector(keyDown:) ) {
		NSBeep();
	}
}

-(BOOL) acceptsFirstResponder {
	return NO;
}

-(BOOL) becomeFirstResponder
{
	return YES;
}

-(BOOL) resignFirstResponder {
	return YES;
}

@end