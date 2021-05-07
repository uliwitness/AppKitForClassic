#import "NSTextField.h"#import "NSWindow.h"#import "NSColor.h"#import "NSEvent.h"@implementation NSTextField-(void) dealloc{	if( _macTextField ) {		TEDispose( _macTextField );	}	[_stringValue release];		[super dealloc];}-(NSColor*) backgroundColor{	return [NSColor whiteColor];}-(void) mouseDown: (NSEvent*)event{	Point clickPos = QDPointFromNSPoint( [event locationInWindow] );	Rect box;	GrafPtr oldPort;	GetPort( &oldPort );	SetPort( [[self window] macGraphicsPort] );	box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );		TEActivate( _macTextField );	TEClick( clickPos, [event modifierFlags] & NSEventModifierFlagShift, _macTextField );		SetPort( oldPort );}-(void) mouseUp: (NSEvent*)event{}-(void) drawRect: (NSRect)dirtyRect{	GrafPtr oldPort;	Rect outerBox = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );	Rect box = outerBox;	InsetRect( &box, 5, 5 );	GetPort( &oldPort );	SetPort( [[self window] macGraphicsPort] );	SetOrigin( 0, 0 );	ForeColor(blackColor);	BackColor(whiteColor);	TEUpdate( &box, _macTextField );		FrameRect( &outerBox );			SetPort( oldPort );}-(void) viewDidMoveToWindow: (NSWindow*)wd{	if( !_macTextField ) {		Rect scrollableBox;		GrafPtr oldPort;		unsigned len = [_stringValue length];		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );		InsetRect( &box, 5, 5 );		scrollableBox = box;		//scrollableBox.right = 30000;				GetPort( &oldPort );		SetPort( [[self window] macGraphicsPort] );				_macTextField = TENew( &box, &box );				TESetText( [_stringValue cString], len, _macTextField );		TECalText( _macTextField );				SetPort( oldPort );	}}-(NSString*) stringValue{	return _stringValue;}-(void) setStringValue: (NSString*)str{	NSString *oldString = _stringValue;	_stringValue = [str retain];	[oldString release];		if( _macTextField ) {		Rect box;		unsigned len;		GrafPtr oldPort;		GetPort( &oldPort );		SetPort( [[self window] macGraphicsPort] );				len = [_stringValue length];		TESetText( [_stringValue cString], len, _macTextField );		TECalText( _macTextField );		box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );		InsetRect( &box, 5, 5 );		SetOrigin( 0, 0 );		TEUpdate( &box, _macTextField );				SetPort( oldPort );	}}-(void) setFrame: (NSRect)newFrame{	[super setFrame: newFrame];		if( _macTextField ) {		Rect box;		GrafPtr oldPort;		GetPort( &oldPort );		SetPort( [[self window] macGraphicsPort] );		SetOrigin( 0, 0 );				box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );		InsetRect( &box, 5, 5 );		(**_macTextField).destRect = box;		(**_macTextField).viewRect = box;		TECalText( _macTextField );		InvalRect( &box );				SetPort( oldPort );	}}-(void) setTarget: (NSObject*)target{	_target = target;}-(NSObject*) target{	return _target;}-(void) setAction: (SEL)act{	_action = act;}-(SEL) action{	return _action;}-(BOOL) acceptsFirstResponder{	return YES;}-(BOOL) becomeFirstResponder{	if (_macTextField) {		GrafPtr oldPort;		Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );		GetPort( &oldPort );		SetPort( [[self window] macGraphicsPort] );		TEActivate( _macTextField );		TESetSelect( 0, (**_macTextField).teLength, _macTextField );		InvalRect( &box );		SetPort( oldPort );	}	return YES;}-(BOOL) resignFirstResponder{	if (_macTextField) {		TEDeactivate( _macTextField );	}	return YES;}-(void) keyDown: (NSEvent*)event{	GrafPtr oldPort;	Rect box = QDRectFromNSRect( [self convertRect: [self bounds] toView: nil] );	GetPort( &oldPort );	SetPort( [[self window] macGraphicsPort] );	TEKey( [[event characters] cString][0], _macTextField );	SetPort( oldPort );}@end