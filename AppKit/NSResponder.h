#import "Foundation.h"

@class NSEvent;

@class NSResponder;

@interface NSResponder : NSObject
{
	NSResponder *_nextResponder;
}

-(NSResponder*) nextResponder;
-(void) setNextResponder: (NSResponder*)next;

-(void) mouseDown: (NSEvent*)event;
-(void) mouseUp: (NSEvent*)event;
-(void) keyDown: (NSEvent*)event;
-(void) keyUp: (NSEvent*)event;

-(void) noResponderFor: (SEL)eventSelector;

-(BOOL) acceptsFirstResponder;
-(BOOL) becomeFirstResponder;
-(BOOL) resignFirstResponder;

@end