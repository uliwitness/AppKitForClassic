#import "NSGraphicsContext.h"
#include <stdlib.h>


NSGraphicsContext * gCurrentContext = nil;


@implementation NSGraphicsContext

-(id) initWithGraphicsPort: (GrafPtr)port
{
	self = [super init];
	if( self ) {
		_macPort = port;
	}
	
	return self;
}

-(void) dealloc
{
	if( _savedState ) {
		unsigned x;
		for( x = 0; x < _savedStateCount; ++x ) {
			DisposeRgn(_savedState[x]._savedClip);
		}
	
		free(_savedState);
		_savedState = NULL;
	}
	
	[super dealloc];
}

+(NSGraphicsContext*) currentContext
{
	return gCurrentContext;
}

+(void) setCurrentContext: (NSGraphicsContext*)context
{
	gCurrentContext = context;
	SetPort( context->_macPort );
}

-(void) saveGraphicsState
{
	GrafPtr oldPort = NULL;
	GetPort( &oldPort );
	SetPort( _macPort );
	if( _savedState == NULL ) {
		_savedState = malloc(sizeof(struct SavedGraphicsState));
		if( _savedState ) {
			_savedState[_savedStateCount]._savedOrigin.h = _macPort->portRect.left;
			_savedState[_savedStateCount]._savedOrigin.v = _macPort->portRect.top;
			_savedState[_savedStateCount]._savedClip = NewRgn();
			GetClip(_savedState[_savedStateCount]._savedClip);
			GetForeColor(&_savedState[_savedStateCount - 1]._foreColor);
			GetBackColor(&_savedState[_savedStateCount - 1]._backColor);
			GetPen(&_savedState[_savedStateCount - 1]._lineWidth);
			_savedState[_savedStateCount - 1]._context = [gCurrentContext retain];
			++_savedStateCount;
		}
	} else {
		struct SavedGraphicsState *newState = realloc(_savedState, sizeof(struct SavedGraphicsState) * (_savedStateCount +1));
		if( newState ) {
			_savedState = newState;
			_savedState[_savedStateCount]._savedOrigin.h = _macPort->portRect.left;
			_savedState[_savedStateCount]._savedOrigin.v = _macPort->portRect.top;
			_savedState[_savedStateCount]._savedClip = NewRgn();
			GetClip(_savedState[_savedStateCount]._savedClip);
			GetForeColor(&_savedState[_savedStateCount - 1]._foreColor);
			GetBackColor(&_savedState[_savedStateCount - 1]._backColor);
			GetPen(&_savedState[_savedStateCount - 1]._lineWidth);
			_savedState[_savedStateCount - 1]._context = [gCurrentContext retain];
			++_savedStateCount;
		}
	}
	SetPort( oldPort );
}

-(void) restoreGraphicsState
{
	if( _savedState != NULL && _savedStateCount > 0 ) {
		NSGraphicsContext * oldContext = gCurrentContext;
		gCurrentContext = [_savedState[_savedStateCount - 1]._context retain];
		if( gCurrentContext ) {
			SetPort( gCurrentContext->_macPort );
		}
		[oldContext release];
		[_savedState[_savedStateCount - 1]._context release];
		SetOrigin(_savedState[_savedStateCount - 1]._savedOrigin.h, _savedState[_savedStateCount - 1]._savedOrigin.v);
		SetClip(_savedState[_savedStateCount - 1]._savedClip);
		DisposeRgn(_savedState[_savedStateCount - 1]._savedClip);
		RGBForeColor(&_savedState[_savedStateCount - 1]._foreColor);
		RGBBackColor(&_savedState[_savedStateCount - 1]._backColor);
		PenSize(_savedState[_savedStateCount - 1]._lineWidth.h, _savedState[_savedStateCount - 1]._lineWidth.v);
		--_savedStateCount;
	}
}

-(GrafPtr) macGraphicsPort
{
	return _macPort;
}

@end

@implementation NSBezierPath
{
	RgnHandle _macRegion;
}

+(void) strokeRect: (NSRect)box {
	Rect qdBox = QDRectFromNSRect(box);
	GrafPtr oldPort = NULL;
	GetPort( &oldPort );
	SetPort( [gCurrentContext macGraphicsPort] );
	
	FrameRect( &qdBox );
	
	SetPort( oldPort );
}

+(void) fillRect: (NSRect)box {
	Rect qdBox = QDRectFromNSRect(box);
	GrafPtr oldPort = NULL;
	GetPort( &oldPort );
	SetPort( [gCurrentContext macGraphicsPort] );
	
	PaintRect( &qdBox );
	
	SetPort( oldPort );
}

+(void) clipRect: (NSRect)box {
	Rect qdBox = QDRectFromNSRect(box);
	GrafPtr oldPort = NULL;
	GetPort( &oldPort );
	SetPort( [gCurrentContext macGraphicsPort] );
	
	ClipRect( &qdBox );
	
	SetPort( oldPort );
}

+(void) strokeLineFromPoint: (NSPoint)start toPoint: (NSPoint)end {
	GrafPtr oldPort = NULL;
	GetPort( &oldPort );
	SetPort( [gCurrentContext macGraphicsPort] );
	
	MoveTo( start.x, start.y );
	LineTo( end.x, end.y );
	
	SetPort( oldPort );
}

-(id) init
{
	self = [super init];
	if( self ) {
		_macRegion = NewRgn();
	}
	
	return self;
}

-(void) dealloc
{
	DisposeRgn( _macRegion );
	
	[super dealloc];
}

-(RgnHandle) macRegion
{
	return _macRegion;
}

@end