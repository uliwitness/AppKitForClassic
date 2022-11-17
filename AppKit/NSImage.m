#import "NSImage.h"
#import "NSIconFamilyImageRep.h"

@implementation NSImage

-(id) initWithRepresentation: (NSImageRep*)rep {
	self = [super init];
	if (self) {
		_representations = [[NSMutableArray alloc] initWithObjects: &(id)rep count: 1];
	}
	return self;
}

-(void) dealloc {
	[_representations release];
	_representations = nil;
	
	[super dealloc];
}

-(id) initWithIconFamilyResource: (short)resID {
	NSImageRep *rep = [[NSIconFamilyImageRep alloc] initWithIconFamilyResource: resID];
	self = [self initWithRepresentation: rep];
	[rep release];
	return self;
}

-(NSSize) size {
	return [[_representations objectAtIndex: 0] size];
}

-(void) drawInRect: (NSRect)box {
	[[_representations objectAtIndex: 0] drawInRect: box];
}

@end

@implementation NSImageRep

-(NSSize) size {
	return NSZeroSize;
}

-(void) drawInRect: (NSRect)box {

}

@end
