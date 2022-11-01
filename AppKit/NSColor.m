#import "NSColor.h"
#import "NSGraphicsContext.h"

@implementation NSColor

-(id) initWithRed: (float)r green: (float)g blue: (float)b
{
	self = [super init];
	if( self ) {
		_macColor.red = (short)(65535.0 * r);
		_macColor.green = (short)(65535.0 * g);
		_macColor.blue = (short)(65535.0 * b);
	}
	
	return self;
}

-(void) set
{
	RGBForeColor( &_macColor );
	RGBBackColor( &_macColor );
}

-(void) setStroke
{
	RGBForeColor( &_macColor );
}

-(void) setFill
{
	RGBBackColor( &_macColor );
}

-(float) redComponent
{
	return ((float)_macColor.red) / 65535.0;
}

-(float) greenComponent
{
	return ((float)_macColor.green) / 65535.0;
}

-(float) blueComponent
{
	return ((float)_macColor.blue) / 65535.0;
}


+(NSColor*) redColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 1.0 green: 0.0 blue: 0.0];
	}
	return c;
}

+(NSColor*) greenColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.0 green: 1.0 blue: 0.0];
	}
	return c;
}


+(NSColor*) blueColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.0 green: 0.0 blue: 1.0];
	}
	return c;
}


+(NSColor*) yellowColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 1.0 green: 1.0 blue: 0.0];
	}
	return c;
}


+(NSColor*) cyanColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.0 green: 1.0 blue: 1.0];
	}
	return c;
}


+(NSColor*) magentaColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 1.0 green: 0.0 blue: 1.0];
	}
	return c;
}


+(NSColor*) orangeColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 1.0 green: 0.65 blue: 0.0];
	}
	return c;
}


+(NSColor*) pinkColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 1.0 green: 0.08 blue: 0.58];
	}
	return c;
}


+(NSColor*) brownColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.65 green: 0.16 blue: 0.16];
	}
	return c;
}


+(NSColor*) whiteColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 1.0 green: 1.0 blue: 1.0];
	}
	return c;
}

+(NSColor*) blackColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.0 green: 0.0 blue: 0.0];
	}
	return c;
}

+(NSColor*) grayColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.5 green: 0.5 blue: 0.5];
	}
	return c;
}

+(NSColor*) lightGrayColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.75 green: 0.75 blue: 0.75];
	}
	return c;
}

+(NSColor*) darkGrayColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.25 green: 0.25 blue: 0.25];
	}
	return c;
}

+(NSColor*) windowBackgroundColor
{
	static NSColor *c = nil;
	if( !c ) {
		c = [[NSColor alloc] initWithRed: 0.9 green: 0.9 blue: 0.9];
	}
	return c;
}

@end