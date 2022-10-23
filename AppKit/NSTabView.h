#import "Runtime.h"
#import "NSView.h"
#import "NSArray.h"

@class NSTabView;
@class NSTabViewItem;

@protocol NSTabViewDelegate <NSObject>

-(void) tabView: (NSTabView*)tabView didSelectTabViewItem: (NSTabViewItem*)tabViewItem;

@end

@interface NSTabViewItem : NSObject
{
	NSString *_label;
	NSString *_identifier;
	NSView *_view;
	NSRect _tabBox;
}

-(void) setLabel: (NSString*)label;
-(NSString*) label;

-(void) setIdentifier: (NSString*)identifier;
-(NSString*) identifier;

-(void) setView: (NSView*)view;
-(NSView*) view;

// Private:
-(void) setTabBox: (NSRect)box;
-(NSRect) tabBox;

@end

@interface NSTabView : NSView
{
	NSTabViewItem *_selectedTabViewItem;
	NSMutableArray *_tabViewItems;
	id<NSTabViewDelegate> _delegate;
}

-(void) addTabViewItem: (NSTabViewItem*)anItem;
-(NSTabViewItem*) tabViewItemAtIndex: (unsigned)idx;

-(void) setDelegate: (id)dele;
-(id) delegate;

// Private:
-(void) layoutTabs;

@end
