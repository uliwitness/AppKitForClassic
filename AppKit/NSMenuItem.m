#import "NSMenuItem.h"
#import "NSMenu.h"
#include <Menus.h>
#include <stdio.h>
#include <limits.h>


@implementation NSMenuItem

-(id) initWithTitle: (NSString*)title target: (id)target action: (SEL)action keyEquivalent: (NSString*)keyEquiv
{
	self = [super init];
	if( self ) {
		_title = [title retain];
		_keyEquivalent = [keyEquiv retain];
		_target = target;
		_action = action;
	}
	
	return self;
}

-(void) dealloc
{
	[_title release];
	[_keyEquivalent release];
	[_submenu release];
	
	[super dealloc];
}

-(id) target
{
	return _target;
}

-(SEL) action
{
	return _action;
}

-(NSMenu*) menu
{
	return _menu;
}

-(void) setMenu: (NSMenu*)parent
{
	_menu = parent;
	[_submenu setSupermenu: _menu];
}

-(NSMenu*) submenu
{
	return _submenu;
}

-(void) setSubmenu: (NSMenu*)child
{
	NSMenu* oldChild = _submenu;
	[oldChild setSupermenu: nil];
	_submenu = [child retain];
	[oldChild release];
	
	[_submenu setSupermenu: _menu];
}

-(void) setEnabled: (BOOL)state
{
	_enabled = state;

	if( _submenu && [_menu supermenu] == nil ) {
		// Ignore top-level menu.
	} else {
		MenuHandle macMenu = [_menu macMenu];
		if(_enabled) {
			EnableItem(macMenu, [[_menu itemArray] indexOfObjectIdenticalTo: self] + 1);
		} else {
			DisableItem(macMenu, [[_menu itemArray] indexOfObjectIdenticalTo: self] + 1);
		}
	}
}


-(BOOL) isEnabled
{
	return _enabled;
}

-(void) install
{
	if( _submenu && [_menu supermenu] == nil ) { // Top-level menu.
		[_submenu install];
	} else {
		MenuHandle macMenu = [_menu macMenu];
		insertmenuitem( macMenu, [_title cString], SHRT_MAX );
		if( _keyEquivalent && [_keyEquivalent length] > 0 ) {
			SetItemCmd( macMenu, CountMItems(macMenu), [_keyEquivalent cString][0]);
		}
		
		if( _submenu ) {
			[_submenu install];
			SetMenuItemHierarchicalID([_menu macMenu], CountMItems([_menu macMenu]), [_submenu menuID]);
		}
	}
}

-(void) debugPrintWithIndent: (int)indent
{
	int x;
	for( x = 0; x < indent; ++x) { printf("\t"); }
	printf("NSMenuItem %p \"%s\" (menu: %p submenu: %p action: %s)\n", self, [_title cString], _menu, _submenu, _action);
	[_submenu debugPrintWithIndent: indent + 1];
}

@end