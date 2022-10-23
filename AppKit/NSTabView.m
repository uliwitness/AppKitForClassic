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

@implementation NSTabViewItem

-(id) init {
	self = [super init];
	if (self) {
		_label = @"Title";
		_view = [[NSView alloc] init];
	}
	return self;
}

-(void) dealloc {
	[_label release];
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
		float tabHeight = 0;
		NSRect tabsArea, contentArea;
		NSTabViewItem *item = [[NSTabViewItem alloc] init];
		_tabViewItems = [[NSMutableArray alloc] init];
		[item setLabel: @"First Tab"];
		[_tabViewItems addObject: item];
		_selectedTabViewItem = item;
		[self addSubview: [item view]];
		[item release];
		item = [[NSTabViewItem alloc] init];
		[item setLabel: @"Second Tab"];
		[_tabViewItems addObject: item];
		[self addSubview: [item view]];
		[item release];

		[self layoutTabs];
		
		tabHeight = [[_tabViewItems objectAtIndex: 0] tabBox].size.height;
		NSDivideRect([self bounds], &tabsArea, &contentArea, tabHeight, NSMinYEdge);
		contentArea = NSInsetRect(CONTENT_INNER_PADDING, CONTENT_INNER_PADDING, contentArea);
		[[[_tabViewItems objectAtIndex: 0] view] setFrame: contentArea];
		[[[_tabViewItems objectAtIndex: 1] view] setFrame: contentArea];
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

	tabHeight = [[_tabViewItems objectAtIndex: 0] tabBox].size.height;
	NSDivideRect([self bounds], &tabsArea, &contentArea, tabHeight, NSMinYEdge);
	contentArea = NSInsetRect(CONTENT_INNER_PADDING, CONTENT_INNER_PADDING, contentArea);

	for (x = 0; x < count; ++x) {
		NSTabViewItem * currentItem = [_tabViewItems objectAtIndex: x];
		
		[[currentItem view] setFrame: contentArea];
	}
}

@end
