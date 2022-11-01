#import "NSMenu.h"
#import "NSMenuItem.h"
#import "NSByteStream.h"
#include <Menus.h>
#include <Resources.h>
#include <stdio.h>
#include <StringCompare.h>


ResID gMenuIDSeed = 128;


@implementation NSMenu

+(NSMenu*) menuFromMBAR: (short)inMBARID {
	short **mbar = (short**) GetResource('MBAR', inMBARID);
	short numMenus = (**mbar);
	short *curID = (*mbar) + 1;
	short x = 0;
	
	NSMenu * mainMenu = [[[NSMenu alloc] initWithTitle: @"MAIN-MENU"] autorelease];
	
	for (x = 0; x < numMenus; ++x) {
		NSMenu * mnu = [[NSMenu alloc] initWithMENU: curID[x]];
		NSMenuItem *parentItem = [[NSMenuItem alloc] initWithTitle: [mnu title] target: nil action: NULL keyEquivalent: nil];
		[parentItem setSubmenu: mnu];
		[mainMenu appendItem: parentItem];
		[parentItem release];
		[mnu release];
	}
	
	return mainMenu;
}

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

-(id) initWithMENU: (short)menuID {
	self = [super init];
	if( self ) {
		NSByteStream *stream = [[NSByteStream alloc] initWithResource: GetResource('MENU', menuID)];
		short menuID = [stream readSInt16];
		short mdefID = 0;
		UInt32 enableFlags = 0;
		Str255 menuTitle = {0};
		//printf("menu ID = %d\n", menuID);
		[stream skip: 4];
		mdefID = [stream readSInt16];
		//printf("mdef ID = %d\n", mdefID);
		[stream skip: 2];
		enableFlags = [stream readUInt32];
		//printf("enableFlags = %lu\n", enableFlags);
		[stream readStr255: menuTitle];
		//printf("menuTitle = %s\n", menuTitle + 1);
		_title = [[NSString alloc] initWithStr255: menuTitle];
		if (gMenuIDSeed == menuID) {
			++gMenuIDSeed;
			printf("Adjusting gMenuIDSeed to %d\n", gMenuIDSeed);
		}
		_macMenu = NewMenu(menuID, menuTitle);
		_itemArray = [[NSMutableArray alloc] init];
		while ([stream bytesLeft] > 1) {
			Str255 itemTitle = {0};
			NSString *titleObject = nil;
			char cmdKey = 0;
			SInt8 markChar = 0;
			NSString *cmdKeyObject = nil;
			NSMenuItem *item = nil;
			NSRange actionMarkerRange = {NSNotFound, 0};
			SEL action = NULL;
			NSString *selString = nil;
			[stream readStr255: itemTitle];
			//printf("%s:\n", itemTitle + 1);
			titleObject = [[NSString alloc] initWithStr255: itemTitle];
			[stream skip: 1];
			cmdKey = [stream readUInt8];
			//printf("\tcmdKey = %d\n", (int)cmdKey);
			markChar = [stream readSInt8];
			//printf("\tmarkChar = %d\n", (int)markChar);
			[stream skip: 1]; // style.
			cmdKeyObject = [[NSString alloc] initWithCharacters: &cmdKey length: cmdKey ? 1 : 0];
			actionMarkerRange = [titleObject rangeOfString: @"\\\\"];
			if (actionMarkerRange.location != NSNotFound) {
				selString = [titleObject substringFromIndex: NSMaxRange(actionMarkerRange)];
				action = NSSelectorFromString(selString);
				titleObject = [titleObject substringToIndex: actionMarkerRange.location];
			}
			item = [[NSMenuItem alloc] initWithTitle: titleObject target: nil action: action keyEquivalent: cmdKeyObject];
			[titleObject release];
			[cmdKeyObject release];
			[self appendItem: item];
			[item setMenu: self];
			[item release];
		}
		[stream release];
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

-(NSString*) title {
	NSString * title = nil;
	HLock((Handle)_macMenu);
	title = [[[NSString alloc] initWithStr255: (**_macMenu).menuData] autorelease];
	HUnlock((Handle)_macMenu);
	return title;
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
		addAppleMenuItems = EqualString((**_macMenu).menuData, "\p", true, true);
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