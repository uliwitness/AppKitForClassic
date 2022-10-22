#import "Foundation.h"
#import "NSView.h"
#import <Controls.h>

@class NSButton;

@interface NSButton : NSView
{
	ControlHandle _macControl;
	NSString *_title;
	NSObject *_target;
	SEL _action;
}

-(NSString*) title;
-(void) setTitle: (NSString*)str;

-(void) setTarget: (NSObject*)target;
-(NSObject*) target;
-(void) setAction: (SEL)act;
-(SEL) action;

@end