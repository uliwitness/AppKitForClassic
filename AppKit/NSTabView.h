#import "NSMiniRuntime.h"
#import "NSView.h"
#import "NSArray.h"
#import "NSImage.h"

@class NSTabView;
@class NSTabViewItem;

@protocol NSTabViewDelegate <NSObject>

-(void) tabView: (NSTabView*)tabView didSelectTabViewItem: (NSTabViewItem*)tabViewItem;

@end

@interface NSTabViewItem : NSObject
{
	NSString *_label;
	NSString *_identifier;
	NSImage *_image;
	NSView *_view;
	NSRect _tabBox;
}

-(void) setLabel: (NSString*)label;
-(NSString*) label;

-(void) setIdentifier: (NSString*)identifier;
-(NSString*) identifier;

-(void) setView: (NSView*)view;
-(NSView*) view;

-(void) setImage: (NSImage*)img;
-(NSImage*) image;

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

-(void) selectTabViewItem: (NSTabViewItem*)currentItem;
-(void) selectTabViewItemAtIndex: (unsigned)itemIndex;
-(NSTabViewItem*) selectedTabViewItem;

-(void) setDelegate: (id)dele;
-(id) delegate;

// Private:
-(void) layoutTabs;

@end
