#import "Foundation.h"
#import "NSView.h"
#import <Controls.h>

@class NSButton;

typedef enum _NSButtonType {
	NSButtonTypeSwitch = 3,
	NSButtonTypeRadio = 4,
	NSButtonTypeMomentaryPushIn = 7
} NSButtonType;

typedef enum _NSControlState {
	NSOnState = 1,
	NSOffState = 0
} NSControlState;

@interface NSButton : NSView
{
	ControlHandle _macControl;
	NSString *_title;
	NSObject *_target;
	SEL _action;
	NSButtonType _type;
	NSString *_shortcut;
}

-(NSString*) title;
-(void) setTitle: (NSString*)str;

-(void) setTarget: (NSObject*)target;
-(NSObject*) target;
-(void) setAction: (SEL)act;
-(SEL) action;

-(void) setButtonType: (NSButtonType)type;

-(void) setState: (NSControlState)state;
-(NSControlState) state;
-(void) setNextState;

-(void) setKeyEquivalent: (NSString*)shortcut;

@end