#import "NSView.h"
#import "NSWindow.h"
#import "NSColor.h"
#import "NSEvent.h"
#import "NSGraphicsContext.h"
#import "ToolboxHider.h"
#import "NSCursor.h"
#import "NSMiniRuntime.h"
#import "NSDefaultButtonOutline.h"
#import "NSProgressIndicator.h"
#import "NSTabView.h"
#import "NSTextField.h"
#import "NSByteStream.h"
#import "NSButton.h"
#include <Quickdraw.h>
#include <Balloons.h>
#include <Resources.h>
#include <stdio.h>


NSView* gCurrentMouseView = nil;


@implementation NSView

-(id) init {
	return [self initWithFrame: NSZeroRect];
}

-(id) initWithFrame: (NSRect)frame
{
	self = [super init];
	if( self ) {
		_frame = frame;
		_subviews = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void) dealloc
{
	gCurrentMouseView = nil;
	[_subviews release];
	_subviews = nil;
	[_toolTip release];
	_toolTip = nil;
	
	[super dealloc];
}

-(NSColor*) backgroundColor
{
	return [[self superview] backgroundColor];
}

-(void) drawRect: (NSRect)dirtyRect
{
	//Rect box = QDRectFromNSRect( [self bounds] );
	//[[NSColor yellowColor] setStroke];
	//FrameRect( &box );
}

-(void) _drawRect: (NSRect)dirtyRect withOffset: (NSPoint)pos {
	int count, x;
#if CLIP_VIEWS
	Rect box;
	RgnHandle oldClip;
#endif

	if (_hidden) {
		return;
	}
	
#if CLIP_VIEWS
	oldClip = NewRgn();
	GetClip(oldClip);
	
	box = QDRectFromNSRect([self bounds]);
	
	SetOrigin( -pos.x, -pos.y );
	ClipRect(&box);
#else
	SetOrigin( -pos.x, -pos.y );
#endif
	
	[[self backgroundColor] set];
	[NSBezierPath fillRect: [self bounds]];
	[[NSColor blackColor] set];
	
	[self drawRect: dirtyRect];
	SetOrigin( 0, 0 );

#if CLIP_VIEWS
	SetClip(oldClip);
	OffsetRect(&box, pos.x, pos.y);
	ClipRect(&box);
#endif
	count = [_subviews count];
	for( x = 0; x < count; ++x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		NSPoint offset = NSMakePoint(pos.x + [currentSubview frame].origin.x, pos.y + [currentSubview frame].origin.y);
		[currentSubview _drawRect: dirtyRect withOffset: offset];
	}
	
#if CLIP_VIEWS
	SetClip(oldClip);
	DisposeRgn(oldClip);
#endif
}

-(void) setNeedsDisplay: (BOOL)state {
	GrafPtr oldPort = NULL;
	NSRect nsBox = [self convertRect: [self bounds] toView: nil];
	Rect qdBox = {0};
	qdBox = QDRectFromNSRect(nsBox);

	GetPort(&oldPort);
	SetPort([[self window] macGraphicsPort]);

	if (state) {
		InvalRect(&qdBox);
	} else {
		ValidRect(&qdBox);
	}
	
	SetPort(oldPort);
}

-(void) setNeedsDisplayInRect: (NSRect)box {
	GrafPtr oldPort = NULL;
	NSRect nsBox = [self convertRect: box toView: nil];
	Rect qdBox = {0};
	qdBox = QDRectFromNSRect(nsBox);

	GetPort(&oldPort);
	SetPort([[self window] macGraphicsPort]);

	InvalRect(&qdBox);
	
	SetPort(oldPort);
}

-(void) loadSubviewsFromDITL: (short)ditlResID firstResponder: (NSResponder**)outResponder {
	Rect defaultOutlineBox = {0,0,0,0};
	Handle ditl = GetResource('DITL', ditlResID);
	NSByteStream *stream = [[NSByteStream alloc] initWithResource: ditl];
	short x = 0, numItems = [stream readUInt16];
	if (!ditl) {
		return;
	}
	for (x = 0; x <= numItems; ++x) {
		Rect	itemBox = {0};
		UInt8	itemType = 0;
		Str255	itemText = {0};
		NSRect	nsItemBox = {0};
		NSString * text = nil;
		NSArray * parameters = nil;
		Boolean isEnabled = false;
		
		[stream skip: sizeof(UInt32)];
		[stream readRect: &itemBox];
		itemType = [stream readUInt8];
		isEnabled = (itemType & 0x80) != 0;
		itemType &= ~0x80;
		[stream readStr255: itemText];
		[stream alignOn: 2];
		nsItemBox = NSRectFromQDRect(itemBox);
		text = [[NSString alloc] initWithStr255: itemText];
		parameters = [text componentsSeparatedByString: @"\\\\"];
		if ([parameters count] > 1) {
			text = [parameters objectAtIndex: 0];
		}
		
		switch (itemType) {
			case 4: {
				BOOL isDefault = defaultOutlineBox.left < itemBox.left
					&& defaultOutlineBox.top < itemBox.top
					&& defaultOutlineBox.right > itemBox.right
					&& defaultOutlineBox.bottom > itemBox.bottom;
				NSButton *bt = [[NSButton alloc] initWithFrame: nsItemBox];
				[bt setTitle: text];
				if (isDefault) {
					[bt setKeyEquivalent: @"\r"];
				}
				if ([parameters count] > 1) {
					[bt setAction: NSSelectorFromString([parameters objectAtIndex: 1])];
				}
				[self addSubview: bt];
				[bt release];
				break;
			}
			
			case 5: {
				NSButton *cb = [[NSButton alloc] initWithFrame: nsItemBox];
				[cb setTitle: text];
				[cb setButtonType: NSButtonTypeSwitch];
				[self addSubview: cb];
				[cb release];
				break;
			}
			
			case 6: {
				NSButton *rb = [[NSButton alloc] initWithFrame: nsItemBox];
				[rb setTitle: text];
				[rb setButtonType: NSButtonTypeRadio];
				[self addSubview: rb];
				[rb release];
				break;
			}
			
			case 7:
				if (itemText[0] >= 2) {
					short currVal, max, min, cdefID;
					Handle cntl = NULL;
					NSByteStream *cntlStream = nil;
					short cntlResID = 0;
					BlockMoveData(itemText + 1, &cntlResID, sizeof(cntlResID));
					cntl = GetResource('CNTL', cntlResID);
					cntlStream = [[NSByteStream alloc] initWithResource: cntl];
					[cntlStream readRect: &itemBox];
					nsItemBox = NSRectFromQDRect(itemBox);
					currVal = [cntlStream readSInt16];
					[cntlStream skip: 2]; // visible
					max = [cntlStream readSInt16];
					min = [cntlStream readSInt16];
					cdefID = [cntlStream readSInt16];
					[cntlStream skip: 4];
					[cntlStream readStr255: itemText];
					[cntlStream release];
					
					switch (cdefID) {
						case kControlProgressBarProc: { // progress bar.
							NSProgressIndicator *pv = [[NSProgressIndicator alloc] initWithFrame: nsItemBox];
							[pv setDoubleValue: currVal];
							[pv setMinValue: min];
							[pv setMaxValue: max];
							[self addSubview: pv];
							[pv release];
							break;
						}
						case kControlChasingArrowsProc: { // tiny indeterminate progress "spinner".
							NSProgressIndicator *pv = [[NSProgressIndicator alloc] initWithFrame: nsItemBox];
							[pv setDoubleValue: currVal];
							[pv setMinValue: min];
							[pv setMaxValue: max];
							[pv setStyle: NSProgressIndicatorSpinningStyle];
							[self addSubview: pv];
							[pv release];
							break;
						}
						case kControlTabLargeNorthProc:
						case kControlTabSmallNorthProc:
						case kControlTabLargeSouthProc:
						case kControlTabSmallSouthProc:
						case kControlTabLargeEastProc:
						case kControlTabSmallEastProc:
						case kControlTabLargeWestProc:
						case kControlTabSmallWestProc: { // tab control.
							NSTabView *tc = nil;
							short numTabs = 0, x = 0;
							Str255 tabName;
							NSByteStream *tabStream = [[NSByteStream alloc] initWithResource: GetResource('tab#',currVal)];
							tc = [[NSTabView alloc] initWithFrame: nsItemBox];
							[tabStream skip: 2]; // version.
							numTabs = [tabStream readUInt16];
							for (x = 0; x < numTabs; ++x) {
								NSString *tabNameObject = nil;
								NSTabViewItem * item = [[NSTabViewItem alloc] init];
								short iconID = [tabStream readSInt16];
								[tabStream readStr255: tabName];
								[tabStream skip: 4];
								[tabStream skip: 2];
								tabNameObject = [[NSString alloc] initWithStr255: tabName];
								[item setLabel: tabNameObject];
								if (iconID != 0) {
									NSImage * img = [[NSImage alloc] initWithIconFamilyResource: iconID];
									[item setImage: img];
									[img release];
								}
								[tc addTabViewItem: item];
								[tabNameObject release];
								[item release];
							}
							[tabStream release];
							tabStream = [[NSByteStream alloc] initWithResource: GetResource('TABs',currVal)];
							numTabs = [tabStream readUInt16];
							for (x = 0; x < numTabs; ++x) {
								short ditlResID = 0;
								Str255 tabIdentifier;
								NSString *tabIdentifierObject = nil;
								NSTabViewItem * item = [tc tabViewItemAtIndex: x];
								[tabStream readStr255: tabIdentifier];
								ditlResID = [tabStream readSInt16];
								tabIdentifierObject = [[NSString alloc] initWithStr255: tabIdentifier];
								[item setIdentifier: tabIdentifierObject];
								[tabIdentifierObject release];
								[[item view] loadSubviewsFromDITL: ditlResID firstResponder: NULL];
							}
							[tabStream release];

							[self addSubview: tc];
							[tc release];
							break;
						}
					}
				}
				break;
			
			case 8:
				if ((itemText[0] > 2) && (itemText[1] == '\\') && (itemText[2] == '\\')) {
					char className[256];
					Class theClass;
					NSTextField *cv = nil;
					BlockMoveData(itemText + 3, className, itemText[0] - 2);
					className[itemText[0] - 2] = 0;
					theClass = objc_getClass(className);
					if (theClass == [NSDefaultButtonOutline class]) {
						defaultOutlineBox = itemBox;
					}
					cv = [[theClass alloc] initWithFrame: nsItemBox];
					[self addSubview: cv];
					if (outResponder && !(*outResponder) && [cv acceptsFirstResponder]) {
						(*outResponder) = cv;
					}
					[cv release];
				} else {
					NSTextField *sf = [[NSTextField alloc] initWithFrame: nsItemBox];
					//printf("%s<%p> refcount after creation: %u\n", ISA_TO_PTR(sf->isa)->name, sf, [sf retainCount]);
					[sf setStringValue: text];
					[self addSubview: sf];
					//printf("%s<%p> refcount after adding: %u\n", ISA_TO_PTR(sf->isa)->name, sf, [sf retainCount]);
					//printf("adding text field:\n");
					//[sf debugPrintWithIndent: 1];
					[sf release];
					//printf("added text field.\n");
				}
				break;
			
			case 16: {
				NSTextField *ef = [[NSTextField alloc] initWithFrame: NSInsetRect(-4, -4, nsItemBox)];
				//printf("%s<%p> refcount after creation: %u\n", ISA_TO_PTR(ef->isa)->name, ef, [ef retainCount]);
				[ef setBezeled: YES];
				[ef setStringValue: text];
				[self addSubview: ef];
				//printf("%s<%p> refcount after adding: %u\n", ISA_TO_PTR(ef->isa)->name, ef, [ef retainCount]);
				if (outResponder && !(*outResponder)) {
					(*outResponder) = ef;
				}
				//printf("adding edit field:\n");
				//[ef debugPrintWithIndent: 1];
				[ef release];
				//printf("added edit field.\n");
				break;
			}
			
			default: {
				NSView *vw = [[NSView alloc] initWithFrame: nsItemBox];
				[self addSubview: vw];
				[vw release];
				break;
			}
		}
		[text release];	
	}
	[stream release];
}

-(NSRect) frame
{
	return _frame;
}


-(void) setFrame: (NSRect)box
{
	_frame = box;
}

-(NSRect) bounds
{
	return NSMakeRect( 0, 0, _frame.size.width, _frame.size.height );
}

-(NSArray*) subviews
{
	return _subviews;
}

-(void) addSubview: (NSView*)view
{
	//printf("adding subview:\n");
	if (view->_superview) {
		printf("WARNING: %s<%p> already has superview %s<%p> when added to %s<%p> [1]\n", ISA_TO_PTR(view->isa)->name, view, ISA_TO_PTR(view->_superview->isa)->name, view->_superview, ISA_TO_PTR(self->isa)->name, self);
	}

	if (!_subviews) {
		printf("ERROR: No _subviews array in %s<%p>.\n", ISA_TO_PTR(self->isa)->name, self);
	}
	[_subviews addObject: view];
	[view setSuperview: self];
		
	//[self debugPrintWithIndent: 1];
	//printf("added subview.\n");
}

-(NSView*) superview
{
	return _superview;
}

-(void) setSuperview: (NSView*)parent
{
	NSWindow * oldWin = [_superview window];
	NSWindow * newWin = [parent window];
	
	if (_superview) {
		printf("WARNING: %s<%p> already has superview %s<%p> when added to %s<%p> [2]\n", ISA_TO_PTR(self->isa)->name, self, ISA_TO_PTR(_superview->isa)->name, _superview, ISA_TO_PTR(parent->isa)->name, parent);
	}

	_superview = parent;
	[self setNextResponder: parent];
	
	if( oldWin != newWin ) {
		[self _viewDidMoveToWindow: newWin];
	}
}

-(NSWindow*) window
{
	return [_superview window];
}

-(void) viewDidMoveToWindow: (NSWindow*)wd
{

}

-(void) _viewDidMoveToWindow: (NSWindow*)wd
{
	int x, count = [_subviews count];
	
	[self viewDidMoveToWindow: wd];
	
	if( _superview == nil ) {
		[self setNextResponder: wd];
	}

	for( x = 0; x < count; ++x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		[currentSubview _viewDidMoveToWindow: wd];
	}
}

-(NSPoint) convertPoint: (NSPoint)pos fromView: (NSView*)view
{
	NSPoint result = pos;
	if( _superview == view ) {
		result.x -= [self frame].origin.x;
		result.y -= [self frame].origin.y;
	} else {
		NSView *currView = self;
		if( view == nil ) {
			view = [[self window] contentView];
		}
		while( currView != nil && currView != view ) {
			result.x -= [currView frame].origin.x;
			result.y -= [currView frame].origin.y;
			
			currView = [currView superview];
		}
	}
	
	return result;
}

-(NSRect) convertRect: (NSRect)box toView: (NSView*)view
{
	NSRect result = box;
	if( _superview == view ) {
		result.origin.x += [self frame].origin.x;
		result.origin.y += [self frame].origin.y;
	} else {
		NSView *currView = self;
		if( view == nil ) {
			view = [[self window] contentView];
		}
		while( currView != nil && currView != view ) {
			result.origin.x += [currView frame].origin.x;
			result.origin.y += [currView frame].origin.y;
			
			currView = [currView superview];
		}
	}
	
	return result;
}


-(void) resizeSubviewsWithOldSize: (NSSize)size
{
	int x, count = [_subviews count];
	
	for( x = 0; x < count; ++x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		[currentSubview resizeWithOldSuperviewSize: size];
	}
}


-(void) resizeWithOldSuperviewSize: (NSSize)size
{
	NSRect myFrame = [self frame];
	NSRect newFrame = myFrame;
	float leftDistance = NSMinX( myFrame );
	float topDistance = NSMinY( myFrame );
	float rightDistance = size.width -NSMaxX( myFrame );
	float bottomDistance = size.height -NSMaxY( myFrame );
	
	if( _autoresizingMask & NSViewMinXMargin ) {
		newFrame.origin.x = leftDistance;
		if( _autoresizingMask & NSViewMaxXMargin ) {
			if( _autoresizingMask & NSViewWidthSizable ) {
				newFrame.size.width = [[self superview] bounds].size.width - leftDistance - rightDistance;
			} else {
				newFrame.origin.x = ([[self superview] bounds].size.width -newFrame.size.width) / 2.0;
			}
		}
	} else if( _autoresizingMask & NSViewMaxXMargin ) {
		newFrame.origin.x = ([[self superview] bounds].size.width -newFrame.size.width -rightDistance);
	}
	
	if( _autoresizingMask & NSViewMinYMargin ) {
		newFrame.origin.y = topDistance;
		if( _autoresizingMask & NSViewMaxYMargin ) {
			if( _autoresizingMask & NSViewHeightSizable ) {
				newFrame.size.height = [[self superview] bounds].size.height - topDistance - bottomDistance;
			} else {
				newFrame.origin.y = ([[self superview] bounds].size.height -newFrame.size.height) / 2.0;
			}
		}
	} else if( _autoresizingMask & NSViewMaxYMargin ) {
		newFrame.origin.y = ([[self superview] bounds].size.height -newFrame.size.height -bottomDistance);
	}
	
	[self setFrame: newFrame];
	
	[self resizeSubviewsWithOldSize: myFrame.size];
}


-(NSAutoresizingMaskOptions) autoresizingMask
{
	return _autoresizingMask;
}


-(void) setAutoresizingMask: (NSAutoresizingMaskOptions)mask
{
	_autoresizingMask = mask;
}


-(void) mouseDown: (NSEvent*)event
{
	//NSBeep();
}

-(void) mouseEntered: (NSEvent*)event {
	[[NSCursor arrowCursor] set];
	if (_toolTip && HMGetBalloons() && !HMIsBalloon()) {
		OSErr err;
		Point tipPos;
		NSRect wdBox = [[self window] frame];
		NSRect globalBox = [self convertRect: [self bounds] toView: nil];
		Rect globalQDBox;
		HMMessageRecord message;
		globalBox.origin.x += wdBox.origin.x;
		globalBox.origin.y += wdBox.origin.y;
		message.hmmHelpType = khmmString;
		message.u.hmmString[0] = [_toolTip length];
		BlockMoveData([_toolTip cString], message.u.hmmString + 1, message.u.hmmString[0]);
		tipPos.h = NSMidX(globalBox);
		tipPos.v = NSMaxY(globalBox) - 1;
		globalQDBox = QDRectFromNSRect(globalBox);
		err = HMShowBalloon(&message, tipPos,
		                      &globalQDBox,
		                       NULL,
		                       kBalloonWDEFID,
		                       kTopLeftTipPointsUpVariant,
		                       kHMRegularWindow);
		if (err != noErr) {
			printf("balloon error = %d\n", err);
		}
	}
}

-(void) mouseExited: (NSEvent*)event {
	if (_toolTip && HMGetBalloons()) {
		HMRemoveBalloon();
	}
}

-(void) setToolTip: (NSString*)helpText {
	NSString *oldVal = _toolTip;
	_toolTip = [helpText retain];
	[oldVal release];
}

-(NSString*) toolTip {
	return _toolTip;
}

-(void) setHidden: (BOOL)state {
	_hidden = state;
	[self setNeedsDisplay: YES];
}

-(BOOL) isHidden {
	return _hidden;
}


-(BOOL) _mouseDown: (NSEvent*)event
{
	int x, count = 0;
	NSPoint pos;
	NSRect box;

	if (_hidden) {
		return NO;
	}

	count = [_subviews count];

	for( x = (count - 1); x >= 0; --x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		if( [currentSubview _mouseDown: event] ) {
			return YES;
		}
	}
	
	pos = [self convertPoint: [event locationInWindow] fromView: nil];
	box = [self bounds];
	
	if( (pos.x >= box.origin.x) && (pos.y >= box.origin.y)
		&& (pos.x <= (box.origin.x + box.size.width))
		&& (pos.y <= (box.origin.y + box.size.height)) ) {
		[self mouseDown: event];
		return YES;
	}
	
	return NO;
}

-(NSView*) _subviewAtPoint: (NSPoint)pos {
	int x, count = [_subviews count];
	NSRect box;
	
	if (_hidden) {
		return nil;
	}

	count = [_subviews count];

	for( x = (count - 1); x >= 0; --x )
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		NSView * foundSubview = [currentSubview _subviewAtPoint: pos];
		if (foundSubview) {
			return foundSubview;
		}
	}
	
	pos = [self convertPoint: pos fromView: nil];
	box = [self bounds];
	
	if( (pos.x >= box.origin.x) && (pos.y >= box.origin.y)
		&& (pos.x <= (box.origin.x + box.size.width))
		&& (pos.y <= (box.origin.y + box.size.height)) ) {
		return self;
	}
	
	return nil;
}

-(RgnHandle) _globalRegion {
	RgnHandle result = NewRgn();
	RgnHandle currViewRgn = NewRgn();
	NSRect nsBox = [self convertRect: [self bounds] toView: nil];
	NSPoint wdPos = [[self window] frame].origin;
	Rect qdBox = {0};
	int x, count = [_subviews count];
	NSArray *peers = nil;
	BOOL hadSelf = NO;
	NSRect box;
	nsBox.origin.x += wdPos.x;
	nsBox.origin.y += wdPos.y;
	qdBox = QDRectFromNSRect(nsBox);
	RectRgn(result, &qdBox);
	
	for(x = 0; x < count; ++x)
	{
		NSView * currentSubview = [_subviews objectAtIndex: x];
		box = [currentSubview convertRect: [currentSubview bounds] toView: nil];
		SetRectRgn(currViewRgn, NSMinX(box), NSMinY(box), NSMaxX(box), NSMaxY(box));
		DiffRgn(currViewRgn, result, result);
	}
	
	peers = [_superview subviews];
	count = [peers count];
	for(x = 0; x < count; ++x)
	{
		NSView * currentSubview = [peers objectAtIndex: x];
		if (currentSubview == self) {
			hadSelf = YES;
		} else if (hadSelf) { // Remove peer views on top of us.
			box = [currentSubview convertRect: [currentSubview bounds] toView: nil];
			SetRectRgn(currViewRgn, NSMinX(box), NSMinY(box), NSMaxX(box), NSMaxY(box));
			DiffRgn(currViewRgn, result, result);
		} // else ignore views below us.
	}
	
	DisposeRgn(currViewRgn);
	
	return result;
}

-(void) debugPrintWithIndent: (unsigned)depth {
	char* indent = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t";
	unsigned x = 0, count = 0;
	for (x = 0; x < depth; ++x) {
		printf("%c", indent[x]);
	}
	
	count = [_subviews count];
	printf("%s<%p> (%u subviews, superview %s<%p>)\n", [self class]->name, self, count, ISA_TO_PTR(_superview->isa)->name, _superview);
	
	for (x = 0; x < count; ++x) {
		NSView * subview = [_subviews objectAtIndex: x];
		[subview debugPrintWithIndent: depth + 1];
	}
}

@end

@implementation NSWindowContentView

-(id) initWithFrame: (NSRect)box
{
	self = [super initWithFrame: box];
	if( self ) {
		_backgroundColor = [[NSColor pinkColor] retain];
	}
	
	return self;
}

-(void) dealloc
{
	[_backgroundColor release];
	
	[super dealloc];
}

-(NSWindow*) window
{
	return _window;
}

-(void) setWindow:(NSWindow*)win
{
	if( win != _window ) {
		_window = win;
		[self setNextResponder: win];
		
		[self _viewDidMoveToWindow: win];
	}
}

-(NSColor*) backgroundColor
{
	return _backgroundColor;
}

-(void) setBackgroundColor: (NSColor*)c
{
	NSColor *oldColor = _backgroundColor;
	_backgroundColor = [c retain];
	[oldColor release];
}

@end