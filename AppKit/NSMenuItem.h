#import "Foundation.h"
#include <Menus.h>


@class NSMenu;

@class NSMenuItem;

@interface NSMenuItem : NSObject
{
	NSString *_title;
	NSString *_keyEquivalent;
	NSObject* _target;
	SEL _action;
	NSMenu *_menu;
	NSMenu *_submenu;
	BOOL _enabled;
}

-(id) initWithTitle: (NSString*)title target: (NSObject*)target action: (SEL)action keyEquivalent: (NSString*)keyEquiv;

-(NSObject*) target;
-(SEL) action;

-(NSMenu*) menu;
-(void) setMenu: (NSMenu*)parent;

-(NSMenu*) submenu;
-(void) setSubmenu: (NSMenu*)parent;

-(void) setEnabled: (BOOL)state;
-(BOOL) isEnabled;

// Private:
-(void) install;
-(void) debugPrintWithIndent: (int)indent;

@end

@protocol NSMenuItemTarget

-(BOOL) validateMenuItem: (NSMenuItem*)sender;

@end