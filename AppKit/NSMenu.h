#import "Foundation.h"
#include <Menus.h>
#include <Resources.h>

@class NSMenuItem;

@class NSMenu;

@interface NSMenu : NSObject
{
	NSString* _title;
	MenuHandle _macMenu;
	NSMenu *_supermenu;
	NSMutableArray *_itemArray;
}

-(id) initWithTitle: (NSString*)macEvent;

-(NSMutableArray*) itemArray;
-(void) appendItem: (NSMenuItem*)item;

-(NSMenu*) supermenu;
-(void) setSupermenu: (NSMenu*)parent;

// Private:
-(void) install;

-(MenuHandle) macMenu;
-(ResID) menuID;
-(void) debugPrintWithIndent: (int)indent;

-(NSMenu*) menuByID: (ResID)menuID;

@end