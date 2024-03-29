#import "Foundation.h"
#import "NSWindow.h"
#include <Events.h>

typedef enum _NSEventModifierFlags {
	NSEventModifierFlagShift = shiftKey,
	NSEventModifierFlagControl = controlKey,
	NSEventModifierFlagCommand = cmdKey,
	NSEventModifierFlagCapsLock = alphaLock,
	NSEventModigierFlagOption = optionKey
} NSEventModifierFlags;

@class NSEvent;

@interface NSEvent : NSObject
{
	EventRecord _macEvent;
	NSWindow * _window;
}

-(id) initWithMacEvent: (EventRecord*)macEvent window: (NSWindow*)win;

-(NSPoint) locationInWindow;

-(NSEventModifierFlags) modifierFlags;

-(NSString*) characters;

// Private:
-(EventRecord) macEvent;

@end