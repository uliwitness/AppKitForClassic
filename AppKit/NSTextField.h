#import "Foundation.h"
#import "NSView.h"
#import <TextEdit.h>

@class NSTimer;

@interface NSTextField : NSView
{
	TEHandle _macTextField;
	NSObject *_target;
	SEL _action;
	NSString *_stringValue;
	NSTimer *_caretTimer;
	BOOL _bezeled;
}

-(NSString*) stringValue;
-(void) setStringValue: (NSString*)str;

-(void) setTarget: (NSObject*)target;
-(NSObject*) target;
-(void) setAction: (SEL)act;
-(SEL) action;

-(void) setBezeled: (BOOL)state;

@end