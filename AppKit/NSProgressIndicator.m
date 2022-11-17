#import "NSProgressIndicator.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSCursor.h"
#import "NSApplication.h"
#import "NSTimer.h"
#include "ToolboxHider.h"
#include <stdio.h>

@implementation NSProgressIndicator

-(id) initWithFrame: (NSRect)frame {
	self = [super initWithFrame: frame];
	if (self) {
		_doubleValue = 50;
		_maxValue = 100;
		_indeterminate = YES;
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
	return [[self superview] backgroundColor];
}

-(void) drawRect: (NSRect)dirtyRect
{
	if (_style == NSProgressIndicatorSpinningStyle) {
		short iconID = 7000 +((TickCount() / 12) % 8);
		Rect spinnerBox = QDRectFromNSRect([self bounds]);
		spinnerBox.right = spinnerBox.left + 16;
		spinnerBox.bottom = spinnerBox.top + 16;
		PlotIconID(&spinnerBox, atAbsoluteCenter, ttNone, iconID);
	} else {
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
			
			if (!_indeterminate) {
				RGBForeColor(&lightBlue);
				PaintRect(&trackBox);

				filledBox.right = trackBox.left +(((double) trackBox.right - trackBox.left) * percentage);
				RGBForeColor(&darkGray);
				PaintRect(&filledBox);
			} else {
				short patternID = 7000 +((TickCount() / 6) % 8);
				PixPatHandle pattern = GetPixPat(patternID);
				PenPixPat(pattern);
				PaintRect(&trackBox);
				PenPat(&qd.black);
				DisposePixPat(pattern);
			}
			
			ForeColor(blackColor);
			FrameRect(&trackBox);
		}
	}
}

-(void) viewDidMoveToWindow: (NSWindow*)wd {
	if (!_macControl && NSGetAppearanceVersion() != LONG_MIN) {
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
		if (_indeterminate) {
			Boolean isDefault = _indeterminate;
			SetControlData(_macControl, kControlEntireControl, kControlProgressBarIndeterminateTag,
							sizeof(Boolean), &isDefault);
		}
	}
	if (!_macControl && _indeterminate && !_indeterminateAnimationTimer) {
		_indeterminateAnimationTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(animate:)
													userInfo: nil repeats: YES];
	} else if (_indeterminateAnimationTimer && (_macControl || !_indeterminate || [self window] == nil)) {
		[_indeterminateAnimationTimer invalidate];
		_indeterminateAnimationTimer = nil;
	}
}

-(void) setIndeterminate: (BOOL)state {
	Boolean isDefault = _indeterminate;
	_indeterminate = state;
	if (_macControl) {
		SetControlData(_macControl, kControlEntireControl, kControlProgressBarIndeterminateTag,
						sizeof(Boolean), &isDefault);
	} else if (_indeterminate && [self window]) {
		_indeterminateAnimationTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(animate:)
													userInfo: nil repeats: YES];
	} else if (!_indeterminate || [self window] == nil) {
		[_indeterminateAnimationTimer invalidate];
		_indeterminateAnimationTimer = nil;
	}
}

-(void) animate: (NSTimer*)sender {
	[self setNeedsDisplay: YES];
}

-(BOOL) isIndeterminate {
	return _indeterminate;
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

-(void) setStyle: (NSProgressIndicatorStyle)style {
	_style = style;
	[self setNeedsDisplay: YES];
}

-(NSProgressIndicatorStyle) style {
	return _style;
}

@end