#import "Foundation.h"
#import "NSView.h"
#import <Controls.h>

@interface NSProgressIndicator : NSView
{
	ControlHandle _macControl;
	double _doubleValue;
	double _minValue;
	double _maxValue;
	BOOL _indeterminate;
}

-(id) initWithFrame: (NSRect)frame;

-(void) setDoubleValue: (double)curVal;
-(void) setMinValue: (double)minVal;
-(void) setMaxValue: (double)maxVal;

-(void) setIndeterminate: (BOOL)state;
-(BOOL) isIndeterminate;

@end