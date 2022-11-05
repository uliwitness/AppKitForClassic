#import "NSArray.h"
#import "NSEnumerator.h"
#import "NSString.h"
#include "qsort_context.h"
#import <stdlib.h>
#import <memory.h>
#import <string.h>
#import <stdio.h>

@interface NSArrayEnumerator : NSEnumerator
{
	NSArray *_array;
	unsigned _currentIndex;
}

-(id) initWithArray: (NSArray*)array;

-(id) nextObject;

@end

@implementation NSArray

+(id) arrayWithObjects: (id)firstObject, ... {
	NSArray * result = [[[self alloc] init] autorelease];
	if (result && firstObject) {
		id currObject = nil;
		va_list ap;
		
		result->_storage = malloc(sizeof(id));
		result->_storage[0] = [firstObject retain];
		result->_count = 1;
		
		va_start(ap, firstObject);
		while (true) {
			id* newStorage = NULL;
			currObject = va_arg(ap, id);
			if (!currObject) { break; }
			newStorage = realloc( result->_storage, (result->_count +1) * sizeof(id) );
			if( newStorage ) {
				result->_storage = newStorage;
				result->_storage[result->_count] = [currObject retain];
				++result->_count;
			}
		}
		va_end(ap);
	}
	return result;
}

-(id) initWithObjects: (id*)storage count: (unsigned)count {
	self = [super init];
	if (self && count > 0) {
		unsigned x = 0;
		_storage = malloc(sizeof(id) * count);
		memmove(_storage, storage, sizeof(id) * count);
		_count = count;
		
		for (x = 0; x < count; ++x) {
			[_storage[x] retain];
		}
	}
	return self;
}

-(id) initWithObjects: (id)firstObject, ... {
	self = [super init];
	if (self && firstObject) {
		id currObject = nil;
		va_list ap;
		
		_storage = malloc(sizeof(id));
		_storage[0] = [firstObject retain];
		_count = 1;
		
		va_start(ap, firstObject);
		while (true) {
			id* newStorage = NULL;
			currObject = va_arg(ap, id);
			if (!currObject) { break; }
			newStorage = realloc( _storage, (_count +1) * sizeof(id) );
			if( newStorage ) {
				_storage = newStorage;
				_storage[_count] = [currObject retain];
				++_count;
			}
		}
		va_end(ap);
	}
	return self;
}

-(void) dealloc {
	unsigned x;
	for( x = 0; x < _count; ++x ) {
		[_storage[x] release];
		_storage[x] = nil;
	}
	free(_storage);

	[super dealloc];
}

-(unsigned) count {
	return _count;
}

-(id) objectAtIndex: (unsigned)idx {
	if( idx < _count ) {
		return _storage[idx];
	}
	return nil;
}

-(unsigned) indexOfObjectIdenticalTo: (id)obj {
	unsigned x;
	for( x = 0; x < _count; ++x ) {
		if( obj == _storage[x] ) {
			return x;
		}
	}
	return NSNotFound;
}

-(NSEnumerator*) objectEnumerator {
	return [[[NSArrayEnumerator alloc] initWithArray: self] autorelease];
}

-(id) copy {
	return [self retain];
}

-(id) mutableCopy {
	return [[NSMutableArray alloc] initWithObjects: _storage count: _count];
}

-(NSString*) description {
	NSMutableString *str = [NSMutableString stringWithFormat: @"%s<%p> (\n", [self class]->name, self];
	unsigned x = 0;
	for (x = 0; x < _count; ++x) {
		[str appendFormat: @"\t%@\n", _storage[x]];
	}
	[str appendString: @")"];
	return str;
}

-(NSString*) debugDescription {
	NSMutableString *str = [NSMutableString stringWithFormat: @"%s<%p> (\n", [self class]->name, self];
	unsigned x = 0;
	for (x = 0; x < _count; ++x) {
		[str appendFormat: @"\t%u: %s<%p>\n", x, [_storage[x] class]->name, _storage[x]];
	}
	[str appendString: @")"];
	return str;
}

@end

@implementation NSMutableArray

-(void) addObject: (id)obj {
	//printf("adding %s<%p> to %s<%p>\n", ISA_TO_PTR(obj->isa)->name, obj, ISA_TO_PTR(self->isa)->name, self);
	if( _storage == NULL ) {
		_storage = malloc(sizeof(id));
		if( _storage ) {
			_storage[_count] = [obj retain];
			++_count;
		}
	} else {
		id* newStorage = realloc( _storage, (_count +1) * sizeof(id) );
		if( newStorage ) {
			_storage = newStorage;
			_storage[_count] = [obj retain];
			++_count;
		}
	}
	//printf("added %s<%p> to %s<%p>\n", ISA_TO_PTR(obj->isa)->name, obj, ISA_TO_PTR(self->isa)->name, self);
}

-(void) removeObjectAtIndex: (unsigned)idx {
	id* newStorage;
	unsigned slotsToMove = _count - idx;
	if( idx >= _count) {
		return;
	}
	[_storage[idx] release];
	if(slotsToMove > 0) {
		memmove(_storage + idx, _storage + idx + 1, slotsToMove * sizeof(id));
	}
	--_count;

	newStorage = realloc( _storage, _count * sizeof(id) );
	if( newStorage ) {
		_storage = newStorage;
	}
}

-(void) removeObjectIdenticalTo: (id)obj {
	unsigned idx = [self indexOfObjectIdenticalTo: obj];
	if (idx != NSNotFound) {
		[self removeObjectAtIndex: idx];
	}
}

static int objectCompareFunc(const void* aPtr, const void* bPtr, void* context) {
	int result = 0;
	id a = *(id*)aPtr;
	id b = *(id*)bPtr;
	SEL sel = (SEL)context;
	IMP compareMethodImp = find_method_implementation(a, sel);
	if (compareMethodImp) {
		result = ((int (*)(id,SEL,id)) compareMethodImp)(a, sel, b);
	} else {
		printf("Comparator not found for %p == %p.\n", a, b);
	}
	return result;
}

-(void) sortUsingSelector: (SEL)comparator {
	qsort_context(_storage, _count, sizeof(id), objectCompareFunc, (void*)comparator);
}

-(id) copy {
	return [[NSArray alloc] initWithObjects: _storage count: _count];
}

@end

@implementation NSArrayEnumerator : NSEnumerator

-(id) initWithArray: (NSArray*)array {
	self = [super init];
	if (self) {
		_array = [array retain];
	}
	return self;
}

-(void) dealloc {
	[_array release];
	
	[super dealloc];
}

-(id) nextObject {
	if (_currentIndex >= [_array count]) { return nil; }
	return [_array objectAtIndex: _currentIndex++];
}

@end