#import "NSMenu.h"
#import "NSMenuItem.h"
#include <Menus.h>
#include <Resources.h>
#include <stdio.h>
#include <StringCompare.h>


ResID gMenuIDSeed = 128;


@implementation NSMenu

-(id) initWithTitle: (NSString*)title
{
	self = [super init];
	if( self ) {
		_title = [title retain];
		_macMenu = newmenu( gMenuIDSeed++, [title cString] );
		_itemArray = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void) dealloc
{
	[_title release];
	DisposeMenu(_macMenu);
	[_itemArray release];
	
	[super dealloc];
}

-(NSMutableArray*) itemArray
{
	return _itemArray;
}

-(NSMenu*) supermenu
{
	return _supermenu;
}

-(void) setSupermenu: (NSMenu*)parent
{
	_supermenu = parent;
}

-(void) install
{
	int x;
	int menuCount = [_itemArray count];

	BOOL addAppleMenuItems = NO;
	if( _supermenu && [_supermenu supermenu] == nil ) { // Top-level menu.
		InsertMenu(_macMenu, 0); // Append.
		addAppleMenuItems = EqualString((**_macMenu).menuData, "\p", true, true);
	} else if( _supermenu ) {
		InsertMenu(_macMenu, hierMenu);
	} else { // "main" menu (i.e. menu bar).
		ClearMenuBar();
		InvalMenuBar();
	}
			
	for( x = 0; x < menuCount; ++x ) {
		NSMenuItem * currentItem = [_itemArray objectAtIndex: x];
		[currentItem install];
	}
	
	if( addAppleMenuItems ) {
		AppendResMenu(_macMenu, 'DRVR');
	}
}

-(MenuHandle) macMenu
{
	return _macMenu;
}

-(ResID) menuID
{
	return (**_macMenu).menuID;
}

-(void) appendItem: (NSMenuItem*)item
{
	[_itemArray addObject: item];
	[item setMenu: self];
}


-(void) debugPrintWithIndent: (int)indent
{
	int x;
	unsigned itemCount;
	for( x = 0; x < indent; ++x) { printf("\t"); }
	printf("NSMenu %p \"%s\" (supermenu: %p)\n", self, [_title cString], _supermenu);
	
	itemCount = [_itemArray count];
	for( x = 0; x < itemCount; ++x ) {
		[[_itemArray objectAtIndex: x] debugPrintWithIndent: indent + 1];
	}
}

-(NSMenu*) menuByID: (ResID)menuID
{
	NSMenu * foundMenu = nil;
	int x;
	unsigned itemCount;
	itemCount = [_itemArray count];
	
	if( (**_macMenu).menuID == menuID ) {
		return self;
	}
	
	for( x = 0; x < itemCount && (foundMenu == nil); ++x ) {
		NSMenu * currentSubmenu = [[_itemArray objectAtIndex: x] submenu];
		foundMenu = [currentSubmenu menuByID: menuID];
	}
	return foundMenu;
}

@end