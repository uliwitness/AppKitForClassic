#import "NSArray.h"
#import <stdlib.h>
#import <memory.h>
#import <string.h>
#import <stdio.h>

@implementation NSMutableArray

-(void) dealloc {
	unsigned x;
	for( x = 0; x < _count; ++x ) {
		[_storage[x] release];
		_storage[x] = nil;
	}
	free(_storage);

	[super dealloc];
}

-(unsigned) count
{
	return _count;
}

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

-(id) objectAtIndex: (unsigned)idx {
	if( idx < _count ) {
		return _storage[idx];
	}
	return nil;
}

-(void) removeObjectAtIndex: (unsigned)idx
{
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

-(void) removeObjectIdenticalTo: (id)obj
{
	unsigned idx = [self indexOfObjectIdenticalTo: obj];
	if( idx != NSNotFound ) {
		[self removeObjectAtIndex: idx];
	}
}

-(unsigned) indexOfObjectIdenticalTo: (id)obj
{
	unsigned x;
	for( x = 0; x < _count; ++x ) {
		if( obj == _storage[x] ) {
			return x;
		}
	}
	return NSNotFound;
}

@end