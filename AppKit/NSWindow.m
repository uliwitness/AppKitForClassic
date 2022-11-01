#import "NSWindow.h"
#import "NSEvent.h"
#import "NSView.h"
#import "NSColor.h"
#import "NSGraphicsContext.h"
#import "NSByteStream.h"
#import "NSApplication.h"
#import "NSView+DITLLoading.h"
#import <MacWindows.h>
#import <stdio.h>
#import <Resources.h>
#import <TextUtils.h>
#import <Controls.h>
#include "ToolboxHider.h"


/* DLOG resource:
struct DialogResource {
	Rect frame;
	short wdefID;
	Boolean visible;
	Boolean hasCloseBox;
	UInt32 refCon;
	short ditlID; // DITL resource ID.
	Str255 title;
	// align word
	// UInt16 autoPositioning
};


struct DialogItemsResource {
	UInt16 numItems; // count -1
	struct ItemEntry {
		UInt32 placeholder;
		Rect frame;
		UInt8 itemType;
		Str255 data; // packed.
		UInt8 // align on odd.
	} item[0];
};*/

@implementation NSWindow

-(id) initWithFrame: (NSRect)box title: (NSString*)title
{
	Rect qdBox = QDRectFromNSRect(box);

	self = [super init];
	if (self) {
		_title = [title retain];
		newcwindow(&_macWindow, &qdBox,
                                 [_title cString],
                                 false, /*invisible*/
                                 zoomDocProc,
                                 (WindowPtr) -1, /*frontmost*/
                                 true, /*closeBox*/
                                 (long)self);
        box.origin = NSMakePoint(0,0);
        _contentView = [[NSWindowContentView alloc] initWithFrame: box];
        [_contentView setBackgroundColor: [NSColor windowBackgroundColor]];
        [_contentView setWindow: self];
        _hasWindow = YES;
        _nextResponder = [NSApplication sharedApplication];
        _resizable = YES;
	}
	
	return self;
}

-(id) initWithDLOG: (short)dlogResID
{
	self = [super init];
	if (self) {
		Handle dlog = GetResource('DLOG', dlogResID);
		NSByteStream *stream = [[NSByteStream alloc] initWithResource: dlog];
		Rect qdBox = {0};
		NSRect nsBox = {0};
		short wdefID = 0;
		Boolean visible = false;
		Boolean hasCloseBox = false;
		UInt32 refCon = 0;
		short ditlResID = 0;
		Str255 title = {0};
		UInt16 autoPositioningFlags = 0;
		Handle ditl = NULL;
		short numItems = 0;
		short x = 0;
		
		[stream readRect: &qdBox];
		nsBox = NSRectFromQDRect(qdBox);
		wdefID = [stream readSInt16];
		visible = [stream readBoolean];
		hasCloseBox = [stream readBoolean];
		refCon = [stream readUInt32];
		ditlResID = [stream readSInt16];
		[stream readStr255: title];
		[stream alignOn: 2];
		autoPositioningFlags = [stream readUInt16]; // TODO: Position window based on this.
		[stream release];
		
		switch(wdefID) {
			case documentProc:
			case zoomDocProc:
			case floatGrowProc:
			case floatZoomGrowProc:
			case floatSideGrowProc:
			case floatSideZoomGrowProc:
			case kWindowGrowDocumentProc:
			case kWindowVertZoomGrowDocumentProc:
			case kWindowHorizZoomGrowDocumentProc:
			case kWindowFullZoomGrowDocumentProc:
			case kWindowMovableModalGrowProc:
			case kWindowFloatGrowProc:
			case kWindowFloatVertZoomGrowProc:
			case kWindowFloatHorizZoomGrowProc:
			case kWindowFloatFullZoomGrowProc:
			case kWindowFloatSideGrowProc:
			case kWindowFloatSideVertZoomGrowProc:
			case kWindowFloatSideHorizZoomGrowProc:
			case kWindowFloatSideFullZoomGrowProc:
				_resizable = YES;
				break;
			default:
				_resizable = NO;
		}
		
		_title = [[NSString alloc] initWithStr255: title];
		NewCWindow(& _macWindow, &qdBox,
	                            title,
	                            visible,
	                            wdefID,
	                            (WindowPtr) -1, /*frontmost*/
	                            hasCloseBox,
	                            (long)self);
        _hasWindow = YES;
        nsBox.origin = NSMakePoint(0,0);
	   	_contentView = [[NSWindowContentView alloc] initWithFrame: nsBox];
	   	[_contentView setBackgroundColor: [NSColor windowBackgroundColor]];
		[_contentView setWindow: self];
        _nextResponder = [NSApplication sharedApplication];
		
		// Now load DITL and create its views:
		[_contentView loadSubviewsFromDITL: ditlResID firstResponder: &_firstResponder];
		
		if (_firstResponder) {
			[_firstResponder becomeFirstResponder];
		}
   }
   
   return self;
}

-(void) dealloc
{
	if(_hasWindow) {
		CloseWindow( (GrafPtr)&_macWindow );
		_hasWindow = NO;
	}
	[_title release];
	[_contentView release];

	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return [_contentView backgroundColor];
}

-(void) setBackgroundColor: (NSColor*)c
{
	[_contentView setBackgroundColor: c];
}

-(NSRect) frame {
	Rect box;
	GrafPtr oldPort = NULL;
	Point globalLoc = {0};
	if(!_hasWindow) {
		return NSMakeRect(0,0,0,0);
	}
	box = ((GrafPtr)&_macWindow)->portRect;
	GetPort(&oldPort);
	SetPort((GrafPtr)&_macWindow);
	globalLoc.h = box.left;
	globalLoc.v = box.top;
	LocalToGlobal(&globalLoc);
	SetPort(oldPort);
	OffsetRect(&box, globalLoc.h, globalLoc.v);
	return NSRectFromQDRect(box);
}

-(void) draw
{
	NSGraphicsContext *newCtx;
	Rect growRect;
	NSRect windowContents;
	RgnHandle oldClip;
	UInt32 windowFeatures = 0;
	
	if(!_hasWindow) {
		return;
	}
	newCtx = [[NSGraphicsContext alloc] initWithGraphicsPort: (GrafPtr)&_macWindow];
	growRect = _macWindow.port.portRect;
	windowContents = NSRectFromQDRect(_macWindow.port.portRect);
	oldClip = NewRgn();
	growRect.left = growRect.right - 15;
	growRect.top = growRect.bottom - 15;
	windowContents.origin.x = 0;
	windowContents.origin.y = 0;
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext: newCtx];
	
	[_contentView _drawRect: windowContents withOffset: NSMakePoint(0, 0)];
	
	if (_resizable) {
		GetClip( oldClip );
		ClipRect( &growRect );
		DrawGrowIcon( (GrafPtr)&_macWindow );
		SetClip( oldClip );
	}
	
	[NSGraphicsContext restoreGraphicsState];
	[newCtx release];
}


-(void) activate
{
	if(!_hasWindow) {
		return;
	}
	HiliteWindow((GrafPtr)&_macWindow, true);
}

-(void) deactivate
{
	if(!_hasWindow) {
		return;
	}
	HiliteWindow((GrafPtr)&_macWindow, false);
}


-(NSPoint) convertPoint: (NSPoint)pos fromWindow: (NSWindow*)otherWin
{
	Point localPos = QDPointFromNSPoint(pos);

	if( otherWin == nil && _hasWindow ) {
		GrafPtr oldPort = NULL;
		GetPort( &oldPort );
		SetPort((GrafPtr)&_macWindow);
		
		GlobalToLocal( &localPos );
		
		SetPort( oldPort );
	}
	// TODO: Implement case of otherWin != nil
	
	return NSPointFromQDPoint(localPos);
}

-(void) makeKeyAndOrderFront: (id)sender
{
	if(!_hasWindow) {
		return;
	}
	ShowWindow( (GrafPtr)&_macWindow );
	SelectWindow( (GrafPtr)&_macWindow );
}

-(void) setSize: (NSSize)newSize
{
	GrafPtr oldPort;
	NSRect oldRect;
	NSRect newRect;
	if(!_hasWindow) {
		return;
	}
	oldRect = NSRectFromQDRect(_macWindow.port.portRect);
	newRect = oldRect;

	SizeWindow( (GrafPtr)&_macWindow, newSize.width, newSize.height, false);
	GetPort( &oldPort );
	SetPort( (GrafPtr)&_macWindow );
	InvalRect( &_macWindow.port.portRect );
	SetPort( oldPort );
	
	newRect.size = newSize;
	[_contentView setFrame: newRect];
	[_contentView resizeSubviewsWithOldSize: oldRect.size];
}

-(void) mouseDown: (NSEvent*)event
{
	if(!_hasWindow) {
		return;
	}
	[self makeKeyAndOrderFront: self];
	
	[_contentView _mouseDown: event];
}

-(void) mouseUp: (NSEvent*)event
{
	if(!_hasWindow) {
		return;
	}
	//printf("Mouse released at %f,%f\n", [event locationInWindow].x, [event locationInWindow].y);
}

-(void) performClose: (id)sender
{
	if(!_hasWindow) {
		return;
	}
	
	CloseWindow( (GrafPtr)&_macWindow );
	_hasWindow = NO;
}

-(NSView*) contentView
{
	return _contentView;
}

-(NSResponder*) firstResponder
{
	return _firstResponder;
}

-(BOOL) makeFirstResponder: (NSResponder*)responder
{
	if (_firstResponder == responder) {
		return YES; // Nothing to do, you got what you want.
	}
	if (_firstResponder && ![_firstResponder resignFirstResponder] ) {
		return NO;
	}
	if (responder && ![responder acceptsFirstResponder] ) {
		return NO;
	}
	if (responder && ![responder becomeFirstResponder]) {
		return NO;
	}
	_firstResponder = responder;
	return YES;
}

-(void) selectNextKeyView: (id)sender {
	[self makeFirstResponder: nil];
}

-(GrafPtr) macGraphicsPort
{
	if(!_hasWindow) {
		return NULL;
	}
	
	
	return (GrafPtr) &_macWindow;
}

-(NSView*) _subviewAtPoint: (NSPoint)pos {
	pos = [self convertPoint: pos fromWindow: nil];
	return [_contentView _subviewAtPoint: pos];
}

-(void) orderFrontStandardAboutPanel: (id)sender
{
	printf("Window About panel! WHOOO!\n");
}

-(void) idle: (NSEvent*)event {
	IdleControls((GrafPtr)&_macWindow);
}

+(NSWindow*)windowFromMacWindow: (WindowPtr)window
{
	return (NSWindow*) GetWRefCon(window);
}

@end