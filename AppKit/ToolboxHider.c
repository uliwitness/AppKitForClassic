/*
	Some Toolbox headers declare symbols that conflict with Objective-C symbols or reserved words.
	We hide them in this plain C file and expose them via functions
*/

#include "ToolboxHider.h"
#include <Sound.h>
#include <Gestalt.h>
#include <limits.h>

void NSBeep( void ) {
	SysBeep( 10 );
}

long NSGetAppearanceVersion(void) {
	static long haveAppearance = LONG_MAX;
	//return LONG_MIN;
	if (haveAppearance == LONG_MAX) {
		if (Gestalt(gestaltAppearanceAttr, &haveAppearance) != noErr) {
			haveAppearance = LONG_MIN;
		}
	}
	return haveAppearance;
}