// From ControlDefinitions.h which is ObjC-incompatible:
#define pushButProc 0
#define checkBoxProc 1
#define radioButProc 2
#define kControlProgressBarProc	80

#define inButton 10
#define inCheckBox 11

#define kControlPushButtonDefaultTag FOUR_CHAR_CODE('dflt') 
#define kControlProgressBarIndeterminateTag FOUR_CHAR_CODE('inde')


// Standard Cocoa name for call with ObjC-incompatible header:
void NSBeep(void);

// Returns LONG_MIN on pre-Appearance OSes, Appearance version otherwise.
long NSGetAppearanceVersion(void);