#import "NSArray.h"
#import "NSGeometry.h"

@class NSImageRep;

@interface NSImage : NSObject
{
	NSMutableArray *_representations;
}

-(id) initWithIconFamilyResource: (short)resID;

-(NSSize) size;

-(void) drawInRect: (NSRect)box;

// private:
-(id) initWithRepresentation: (NSImageRep*)rep;

@end


@interface NSImageRep : NSObject

-(NSSize) size;

-(void) drawInRect: (NSRect)box;

@end
