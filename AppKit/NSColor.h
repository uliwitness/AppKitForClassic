#import "Foundation.h"
#include <Quickdraw.h>

@class NSColor;

@interface NSColor : NSObject
{
	RGBColor _macColor;
}

-(id) initWithRed: (float)r green: (float)g blue: (float)b;

-(void) set;
-(void) setStroke;
-(void) setFill;

-(float) redComponent;
-(float) greenComponent;
-(float) blueComponent;

+(NSColor*) redColor;
+(NSColor*) greenColor;
+(NSColor*) blueColor;
+(NSColor*) yellowColor;
+(NSColor*) cyanColor;
+(NSColor*) magentaColor;
+(NSColor*) orangeColor;
+(NSColor*) pinkColor;
+(NSColor*) brownColor;

+(NSColor*) whiteColor;
+(NSColor*) blackColor;
+(NSColor*) grayColor;
+(NSColor*) lightGrayColor;
+(NSColor*) darkGrayColor;

+(NSColor*) windowBackgroundColor;

@end