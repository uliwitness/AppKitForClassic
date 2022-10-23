#import "NSProgressIndicator.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSCursor.h"
#import "NSApplication.h"
//#include <ControlDefinitions.h>

#define kControlProgressBarProc	80


@implementation NSProgressIndicator

-(id) initWithFrame: (NSRect)frame {
	self = [super initWithFrame: frame];
	if (self) {
		_doubleValue = 50;
		_maxValue = 100;
	}
	return self;
}

-(void) dealloc
{
	if (_macControl) {
		DisposeControl(_macControl);
	}
	
	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return [[self window] backgroundColor];
}

-(void) drawRect: (NSRect)dirtyRect
{
	if (_macControl) {
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		SetOrigin( 0, 0 );
		MoveControl( _macControl, box.left, box.top );
		SizeControl( _macControl, box.right - box.left, box.bottom - box.top );
		Draw1Control( _macControl );
	} else {
		Rect trackBox = QDRectFromNSRect([self bounds]);
		Rect filledBox;
		RGBColor lightBlue = {0xCDCD, 0xCBCB, 0xFFFF};
		RGBColor darkGray = {0x5555, 0x5555, 0x5555};
		double percentage = _doubleValue - _minValue;
		percentage /= _maxValue - _minValue;
		
		trackBox.bottom = trackBox.top + 14;
		
		filledBox = trackBox;
		
		RGBForeColor(&lightBlue);
		PaintRect(&trackBox);

		filledBox.right = trackBox.left +(((double) trackBox.right - trackBox.left) * percentage);
		RGBForeColor(&darkGray);
		PaintRect(&filledBox);
		
		ForeColor(blackColor);
		FrameRect(&trackBox);
	}
}

-(void) viewDidMoveToWindow: (NSWindow*)wd {
	if (!_macControl) {
		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );
		_macControl = newcontrol([wd macGraphicsPort],
									&box,
									"",
									true,
									(SInt16)_doubleValue,
									(SInt16)_minValue,
									(SInt16)_maxValue,
									kControlProgressBarProc,
									(long)self);
	}
}

-(void) setDoubleValue: (double)curVal {
	_doubleValue = curVal;
	if (_macControl) {
		SetControlValue(_macControl, (SInt16)curVal);
	}
	[self setNeedsDisplay: YES];
}

-(void) setMinValue: (double)minVal {
	_minValue = minVal;
	if (_macControl) {
		SetControlValue(_macControl, (SInt16)minVal);
	}
	[self setNeedsDisplay: YES];
}

-(void) setMaxValue: (double)maxVal {
	_maxValue = maxVal;
	if (_macControl) {
		SetControlValue(_macControl, (SInt16)maxVal);
	}
	[self setNeedsDisplay: YES];
}

@end