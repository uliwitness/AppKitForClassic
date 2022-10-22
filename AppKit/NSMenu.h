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

+(NSMenu*) menuFromMBAR: (short)inMBARID;

-(id) initWithTitle: (NSString*)title;
-(id) initWithMENU: (short)menuID;

-(NSMutableArray*) itemArray;
-(void) appendItem: (NSMenuItem*)item;

-(NSMenu*) supermenu;
-(void) setSupermenu: (NSMenu*)parent;

-(NSString*) title;

// Private:
-(void) install;

-(MenuHandle) macMenu;
-(ResID) menuID;
-(void) debugPrintWithIndent: (int)indent;

-(NSMenu*) menuByID: (ResID)menuID;

@end