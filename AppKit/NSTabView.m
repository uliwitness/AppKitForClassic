#import "NSTabView.h"
#import "NSGeometry.h"
#import "NSGraphicsContext.h"
#import "NSColor.h"
#import "NSWindow.h"
#import "NSEvent.h"
#include <Quickdraw.h>
#include <Fonts.h>

#define TAB_H_OUTER_PADDING 	8
#define TAB_H_INNER_PADDING 	12
#define TAB_V_INNER_PADDING 	3
#define CONTENT_INNER_PADDING	4

@interface NSTabItemView : NSView
{
	NSColor *_backgroundColor;
}

@end

@implementation NSTabViewItem

-(id) init {
	self = [super init];
	if (self) {
		_label = @"Title";
		_view = [[NSTabItemView alloc] init];
	}
	return self;
}

-(void) dealloc {
	[_label release];
	[_identifier release];
	[_view release];
	
	[super dealloc];
}

-(void) setLabel: (NSString*)label {
	NSString *oldLabel = _label;
	_label = [label retain];
	[oldLabel release];
}

-(NSString*) label {
	return _label;
}

-(void) setIdentifier: (NSString*)identifier {
	NSString *oldIdentifier = _identifier;
	_identifier = [identifier retain];
	[oldIdentifier release];
}

-(NSString*) identifier {
	return _identifier;
}


-(void) setView: (NSView*)view {
	NSView *oldView = _view;
	_view = [view retain];
	[oldView release];
}

-(NSView*) view {
	return _view;
}

-(void) setTabBox: (NSRect)box {
	_tabBox = box;
}

-(NSRect) tabBox {
	return _tabBox;
}

@end

@implementation NSTabView

-(id) initWithFrame: (NSRect)frame {
	self = [super initWithFrame: frame];
	if (self) {
		_tabViewItems = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) dealloc {
	[_tabViewItems release];
	
	[super dealloc];
}

-(NSColor*) backgroundColor {
	return [NSColor whiteColor];
}

-(void) addTabViewItem: (NSTabViewItem*)anItem {
	[_tabViewItems addObject: anItem];
	[self addSubview: [anItem view]];
	if (!_selectedTabViewItem) {
		_selectedTabViewItem = anItem;
	}
	[[anItem view] setHidden: (anItem != _selectedTabViewItem)];
	[self layoutTabs];
}

-(NSTabViewItem*) tabViewItemAtIndex: (unsigned)idx {
	return [_tabViewItems objectAtIndex: idx];
}

-(void) setDelegate: (id)dele {
	_delegate = dele;
}

-(id) delegate {
	return _delegate;
}

static void DrawTab(Rect *currentTab) {
	float curveStartV = (currentTab->bottom - currentTab->top) / 6;
	float curveStartH = TAB_H_INNER_PADDING / 3;
	MoveTo(currentTab->left, currentTab->bottom);
	LineTo(currentTab->left + TAB_H_INNER_PADDING - curveStartH, currentTab->top + curveStartV);
	LineTo(currentTab->left + TAB_H_INNER_PADDING, currentTab->top);
	LineTo(currentTab->right - TAB_H_INNER_PADDING, currentTab->top);
	LineTo(currentTab->right - TAB_H_INNER_PADDING + curveStartH, currentTab->top + curveStartV);
	LineTo(currentTab->right, currentTab->bottom);
}

-(void) layoutTabs {
	GrafPtr oldPort;
	FontInfo fontInfo;
	NSRect tabsArea, contentArea;
	Rect currentTab;
	int x = 0, count = [_tabViewItems count];
	float tabHeight = 0;
	
	GetPort(&oldPort);
	SetPort([[self window] macGraphicsPort]);
	
	TextFont(systemFont);
	TextSize(12);
	TextFace(normal);
	GetFontInfo(&fontInfo);
	tabHeight = fontInfo.leading + fontInfo.ascent + fontInfo.descent + (TAB_V_INNER_PADDING * 2);
	
	NSDivideRect([self bounds], &tabsArea, &contentArea, tabHeight, NSMinYEdge);
	contentArea = NSInsetRect(CONTENT_INNER_PADDING, CONTENT_INNER_PADDING, contentArea);
	currentTab = QDRectFromNSRect(tabsArea);
	currentTab.left += TAB_H_OUTER_PADDING;
	currentTab.right = currentTab.left;
		
	for (x = 0; x < count; ++x) {
		NSTabViewItem * currentItem = [_tabViewItems objectAtIndex: x];
		Str255 tabLabel = {0};
		[[currentItem label] getStr255: tabLabel];
		currentTab.right += StringWidth(tabLabel);
		currentTab.right += TAB_H_INNER_PADDING * 2;
		
		[currentItem setTabBox: NSRectFromQDRect(currentTab)];
		[[currentItem view] setFrame: contentArea];
		
		currentTab.left = currentTab.right;
	}
	
	SetPort(oldPort);
}

-(void) drawRect: (NSRect)dirtyRect {
	FontInfo fontInfo;
	float tabHeight = 0;
	NSRect tabsArea, contentArea;
	int x = 0, count = [_tabViewItems count];
	TextFont(systemFont);
	TextSize(12);
	TextFace(normal);
	GetFontInfo(&fontInfo);
	
	tabHeight = [[_tabViewItems objectAtIndex: 0] tabBox].size.height;
	NSDivideRect([self bounds], &tabsArea, &contentArea, tabHeight, NSMinYEdge);
	
	[[[self superview] backgroundColor] setFill];
	[NSBezierPath fillRect: tabsArea];

	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect: contentArea];
	[[NSColor blackColor] setStroke];
	[NSBezierPath strokeRect: contentArea];
	
	for (x = 0; x < count; ++x) {
		PolyHandle tabBody = NULL;
		NSTabViewItem * currentItem = [_tabViewItems objectAtIndex: x];
		Rect currentTab = QDRectFromNSRect([currentItem tabBox]);
		Str255 tabLabel = {0};
		[[currentItem label] getStr255: tabLabel];
		
		tabBody = OpenPoly();
		DrawTab(&currentTab);
		ClosePoly();
		
		if (_selectedTabViewItem == currentItem) {
			[[NSColor whiteColor] setFill];
		} else {
			[[NSColor lightGrayColor] setFill];
		}
		ErasePoly(tabBody);
		KillPoly(tabBody);
		[[NSColor darkGrayColor] setStroke];
		DrawTab(&currentTab);
		
		if (_selectedTabViewItem == currentItem) {
			[[NSColor blackColor] setStroke];
		} else {
			[[NSColor darkGrayColor] setStroke];
		}
		MoveTo(currentTab.left + TAB_H_INNER_PADDING, currentTab.bottom - TAB_V_INNER_PADDING - fontInfo.descent);
		DrawString(tabLabel);
		
		if (_selectedTabViewItem == currentItem) {
			[[NSColor whiteColor] setStroke];
			MoveTo(currentTab.left, currentTab.bottom);
			LineTo(currentTab.right, currentTab.bottom);
		}
		
		currentTab.left = currentTab.right;
	}
}

-(void) mouseDown: (NSEvent*)event {
	NSPoint pos = [self convertPoint: [event locationInWindow] fromView: nil];
	
	int x = 0, count = [_tabViewItems count];
	for (x = 0; x < count; ++x) {
		NSTabViewItem * currentItem = [_tabViewItems objectAtIndex: x];
		
		if (NSPointInRect(pos, [currentItem tabBox])) {
			NSRect box = [_selectedTabViewItem tabBox];
			box.size.height += 1; // Make sure we also update the separator line.
			[self setNeedsDisplayInRect: box];
			[[_selectedTabViewItem view] setHidden: YES];
			_selectedTabViewItem = currentItem;
			box = [_selectedTabViewItem tabBox];
			box.size.height += 1; // Make sure we also update the separator line.
			[[_selectedTabViewItem view] setHidden: NO];
			[self setNeedsDisplayInRect: box];
			break;
		}
	}
}

-(void) setFrame: (NSRect)box {	
	float tabHeight = 0;
	NSRect tabsArea, contentArea;
	int x = 0, count = [_tabViewItems count];

	[super setFrame: box];

	tabHeight = [[_tabViewItems objectAtIndex: 0] tabBox].size.height;
	NSDivideRect([self bounds], &tabsArea, &contentArea, tabHeight, NSMinYEdge);
	contentArea = NSInsetRect(CONTENT_INNER_PADDING, CONTENT_INNER_PADDING, contentArea);

	for (x = 0; x < count; ++x) {
		NSTabViewItem * currentItem = [_tabViewItems objectAtIndex: x];
		
		[[currentItem view] setFrame: contentArea];
	}
}

@end


static int sCurrentColor = 0;
static NSColor * sColors[4] = {
	nil,
	nil,
	nil,
	nil
};


@implementation NSTabItemView

-(NSColor*) backgroundColor {
	if (!_backgroundColor) {
		if (sColors[0] == nil) {
			sColors[0] = [NSColor cyanColor];
			sColors[1] = [NSColor orangeColor];
			sColors[2] = [NSColor redColor];
			sColors[3] = [NSColor blueColor];
		}
		_backgroundColor = sColors[sCurrentColor];
		++sCurrentColor;
		if (sCurrentColor >= 4) {
			sCurrentColor = 0;
		}
	}
	return _backgroundColor;
}

@end
