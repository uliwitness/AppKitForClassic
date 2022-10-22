#import "NSEvent.h"
#import <memory.h>

@implementation NSEvent

-(id) initWithMacEvent: (EventRecord*)macEvent window: (NSWindow*)win
{
	self = [super init];
	if( self ) {
		_macEvent = *macEvent;
		_window = [win retain];
	}
	
	return self;
}

-(void) dealloc
{
	[_window release];
	
	[super dealloc];
}

-(NSPoint) locationInWindow
{
	return [_window convertPoint: NSPointFromQDPoint(_macEvent.where) fromWindow: nil];
}

-(NSEventModifierFlags) modifierFlags
{
	return (NSEventModifierFlags) _macEvent.modifiers;
}

-(NSString*) characters
{
	char pressedCharacter = _macEvent.message & charCodeMask;
	return [[[NSString alloc] initWithCharacters: &pressedCharacter length: 1] autorelease];
}

-(EventRecord) macEvent
{
	return _macEvent;
}

@end