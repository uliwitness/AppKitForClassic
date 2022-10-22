/*
	Some Toolbox headers declare symbols that conflict with Objective-C symbols or reserved words.
	We hide them in this plain C file and expose them via functions
*/

#include "ToolboxHider.h"
#include <Sound.h>

void NSBeep( void ) {
	SysBeep( 10 );
}
