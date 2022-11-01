#import "NSMiniRuntime.h"
#import "NSView.h"

@interface NSBox : NSView
{
	NSString *_title;
	NSColor *_fillColor;
}

-(void) setTitle: (NSString*)label;
-(NSString*) title;

-(NSColor*) fillColor;
-(void) setFillColor: (NSColor*)c;

@end
