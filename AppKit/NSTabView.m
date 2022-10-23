#import "NSTabView.h"
#import "NSGeometry.h"
#import "NSGraphicsContext.h"
#import "NSColor.h"
#include <Quickdraw.h>
#include <Fonts.h>

#define TAB_H_OUTER_PADDING 	8
#define TAB_H_INNER_PADDING 	12
#define TAB_V_INNER_PADDING 	4

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

@end

@implementation NSTabView

-(id) initWithFrame: (NSRect)frame {
	self = [super initWithFrame: frame];
	if (self) {
		NSTabViewItem *item = [[NSTabViewItem alloc] init];
		_tabViewItems = [[NSMutableArray alloc] init];
		[item setLabel: @"First Tab"];
		[_tabViewItems addObject: item];
		_selectedTabViewItem = item;
		[item release];
		item = [[NSTabViewItem alloc] init];
		[item setLabel: @"Second Tab"];
		[_tabViewItems addObject: item];
		[item release];

	}
	return self;
}

-(void) dealloc {
	[_tabViewItems release];
	
	[super dealloc];
}

-(void) addTabViewItem: (NSTabViewItem*)anItem {
	[_tabViewItems addObject: anItem];
	[self addSubview: [anItem view]];
	if (!_selectedTabViewItem) {
		_selectedTabViewItem = anItem;
	}
	[[anItem view] setHidden: (anItem != _selectedTabViewItem)];
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

-(void) drawRect: (NSRect)dirtyRect {
	FontInfo fontInfo;
	NSRect tabsArea, contentArea;
	Rect currentTab;
	int x = 0, count = [_tabViewItems count];
	float tabHeight = 0;
	TextFont(systemFont);
	TextSize(12);
	TextFace(normal);
	GetFontInfo(&fontInfo);
	tabHeight = fontInfo.leading + fontInfo.ascent + fontInfo.descent + (TAB_V_INNER_PADDING * 2);
	NSDivideRect([self bounds], &tabsArea, &contentArea, tabHeight, NSMinYEdge);
	currentTab = QDRectFromNSRect(tabsArea);
	currentTab.left += TAB_H_OUTER_PADDING;
	currentTab.right = currentTab.left;
	
	[[[self superview] backgroundColor] setFill];
	[NSBezierPath fillRect: tabsArea];

	[[NSColor whiteColor] setFill];
	[NSBezierPath fillRect: contentArea];
	[[NSColor blackColor] setStroke];
	[NSBezierPath strokeRect: contentArea];
	
	for (x = 0; x < count; ++x) {
		PolyHandle tabBody = NULL;
		NSTabViewItem * currentItem = [_tabViewItems objectAtIndex: x];
		Str255 tabLabel = {0};
		[[currentItem label] getStr255: tabLabel];
		currentTab.right += StringWidth(tabLabel);
		currentTab.right += TAB_H_INNER_PADDING * 2;
		
		tabBody = OpenPoly();
		DrawTab(&currentTab);
		ClosePoly();
		
		[[NSColor whiteColor] setFill];
		ErasePoly(tabBody);
		KillPoly(tabBody);
		[[NSColor darkGrayColor] setStroke];
		DrawTab(&currentTab);
		
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

@end
