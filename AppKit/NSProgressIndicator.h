#import "Foundation.h"
#import "NSView.h"
#import <Controls.h>

typedef enum _NSProgressIndicatorStyle {
	NSProgressIndicatorBarStyle,
	NSProgressIndicatorSpinningStyle
} NSProgressIndicatorStyle;

@interface NSProgressIndicator : NSView
{
	ControlHandle _macControl;
	double _doubleValue;
	double _minValue;
	double _maxValue;
	BOOL _indeterminate;
	NSTimer *_indeterminateAnimationTimer;
	NSProgressIndicatorStyle _style;
}

-(id) initWithFrame: (NSRect)frame;

-(void) setDoubleValue: (double)curVal;
-(void) setMinValue: (double)minVal;
-(void) setMaxValue: (double)maxVal;

-(void) setIndeterminate: (BOOL)state;
-(BOOL) isIndeterminate;

-(void) setStyle: (NSProgressIndicatorStyle)style;
-(NSProgressIndicatorStyle) style;

@end