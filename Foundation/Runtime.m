#include "Runtime.h"
#include "NSAutoreleasePool.h"
#include <Memory.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// -----------------------------------------------------------------------------
//	Binary-compatible refCon storage:
//		These contortions are needed so class layout of NSConstantString that
//		The MWObjC compiler creates on disk, which do not have space for a ref
//		count.
// -----------------------------------------------------------------------------

unsigned short index_for_class(Class c);

// Table of classes so we can store a small 16-bit index *and* the 16-bit ref count
//	in one 32-bit isa "pointer".
Class *gClasses = NULL;

unsigned short index_for_class(Class c) {
	int x;
	if( !gClasses ) {
		gClasses = malloc( 1000 * sizeof(Class) );
		memset( gClasses, 0, 1000 * sizeof(Class));
		gClasses[0] = c;
		return 0;
	}
	for( x=0; gClasses[x] != nil; ++x ) {
		if( gClasses[x] == c ) {
			return x;
		}
	}
	gClasses[x] = c;
	return x;
}

// Extract the actual class pointer from an 'isa', which might be an NSConstantString's actual isa pointer,
// or a class created at runtime where alloc has already inserted an index and a refcount.
// We use the low bit as a marker whether it's not a pointer, as all pointers allocated on MacOS are on even addresses,
// so a real object pointer would never have its low bit set.
#define ISA_TO_PTR(isa) ((((unsigned long)(isa)) & kRetainCountInISABit) ? gClasses[CLASS_INDEX_FROM_ISA(isa)] : (isa))

static IMP find_method_implementation(id receiver,SEL sel)
{
	if(receiver!=nil)
	{
		Class		isa;
		const char	*selector_name;

		selector_name=(const char *)sel;
		for(isa=ISA_TO_PTR(receiver->isa); isa; isa=isa->super_class)
		{
			objc_method_list	*mlist;
			int					i,n;
			if((mlist=isa->methodlist)!=NULL)
			{
				for(i=0,n=mlist->method_count; i<n; i++)
				{
					if(strcmp(selector_name,mlist->method_list[i].method_name)==0)
					{
						return mlist->method_list[i].method_imp;
					}
				}
			}
		}
	}
	return NULL;
}

static IMP find_super_implementation(objc_super *argsuper,SEL sel)
{
	id receiver;

	receiver=argsuper->receiver;
	if(receiver!=nil)
	{
		Class		isa;
		const char	*selector_name;

		selector_name=(const char *)sel;
		for(isa=ISA_TO_PTR(receiver->isa); isa; isa=isa->super_class)
		{
			if(isa->isa==argsuper->mclass) break;
		}
		for(; isa; isa=isa->super_class)
		{
			objc_method_list	*mlist;
			int					i,n;
	
			if((mlist=isa->methodlist)!=NULL)
			{
				for(i=0,n=mlist->method_count; i<n; i++)
				{
					if(strcmp(selector_name,mlist->method_list[i].method_name)==0)
					{
						return mlist->method_list[i].method_imp;
					}
				}
			}
		}
	}
	return NULL;
}


@implementation NSObject

+(id) alloc
{
	NSObject*	newobj;

	newobj = (NSObject*)malloc(((Class)self)->instance_size); // allocate instance object
	memset(newobj,0,((Class)self)->instance_size); // clear instance object
	newobj->isa = ISA_FOR_INDEX_AND_REFCOUNT(index_for_class((Class)self), 1); // initialize isa member
	return newobj;
}

-(void)dealloc
{
	free(self);
}

-init
{
	//printf("%s<%p> inited\n", ISA_TO_PTR(self->isa)->name, self);
	//	nothing to initialize
	return self;
}


-(id)retain
{
	if( ((unsigned long)isa) & kRetainCountInISABit ) {
		unsigned long rc = RETAINCOUNT_FROM_ISA(isa) + 1;
		isa = (Class) (((unsigned long)isa & ~kRetainCountMask) | (rc << kRetainCountShift));
		//printf("%s<%p>.retaincount + 1 = %lu\n", ISA_TO_PTR(self->isa)->name, self, RETAINCOUNT_FROM_ISA(isa));
	} else {
		//printf("%s<%p> is constant, skipping retain\n", ISA_TO_PTR(self->isa)->name, self);
	}
	return self;
}

-(void)release
{
	if( ((unsigned long)isa) & kRetainCountInISABit ) { // Not a constant object that got a *real* pointer for its isa?
		unsigned long rc = RETAINCOUNT_FROM_ISA(isa) - 1;
		isa = (Class)(((unsigned long)isa & ~kRetainCountMask) | (rc << kRetainCountShift));
		//printf("%s<%p>.retaincount - 1 = %lu\n", ISA_TO_PTR(self->isa)->name, self, RETAINCOUNT_FROM_ISA(isa));
		if( rc == 0 ) {
			[self dealloc];
		}
	} else {
		//printf("%s<%p> is constant, skipping release\n", ISA_TO_PTR(self->isa)->name, self);
	}
}

-(id) autorelease
{
	[gCurrentPool addObject: self];
	return self;
}

-(unsigned) retainCount {
	if( ((unsigned long)isa) & kRetainCountInISABit ) { // Not a constant object that got a *real* pointer for its isa?
		unsigned long rc = RETAINCOUNT_FROM_ISA(isa);
		return rc;
	} else {
		return 0;
	}
}


-(BOOL)conformsTo:(Protocol *)protocol
{
	objc_protocol_list	*plist;
	Class				cls;
	long				i;

	for(cls=ISA_TO_PTR(self->isa); cls; cls=cls->super_class)
	{
		if((plist=cls->protocols)!=NULL)
		{
			for(i=0; i<plist->count; i++)
			{
				if([plist->list[i] conformsTo:protocol]) return YES;
			}
		}
	}
	return NO;
}

- performSelector:(SEL)aSelector
{
	return ((id(*)(id,SEL))objc_msgSend)(self,aSelector);
}

- performSelector:(SEL)aSelector withObject: (id)arg1
{
	return ((id(*)(id,SEL,id))objc_msgSend)(self, aSelector, arg1);
}

-(BOOL) respondsToSelector: (SEL)aSelector
{
	return find_method_implementation(self, aSelector) != NULL;
}

+(BOOL) respondsToSelector: (SEL)aSelector
{
	return find_method_implementation(self, aSelector) != NULL;
}

+(Class) class
{
	return self;
}

-(Class) class
{
	return ISA_TO_PTR(self->isa);
}

@end


@implementation Protocol
- (const char *)name
{
	return protocol_name;
}
- (BOOL) conformsTo:(Protocol *)protocol
{
	objc_protocol_list	*plist;
	long				i;

	if(strcmp([self name],[protocol name])==0) return YES;
	if((plist=self->protocol_list)!=NULL)
	{
		for(i=0; i<plist->count; i++)
		{
			if([plist->list[i] conformsTo:protocol]) return YES;
		}
	}
	return NO;
}
@end


struct ClassNameEntry {
	char name[256];
	Class classObject;
};


struct ClassNameEntry *gClassNameTable = NULL;
Size gClassNameTableCount = 0;

// Look up a class's actual class object by its string name.
// Class *must* have been registered via objc_registerClass() for this to work.
Class objc_getClass(const char* name) {
	int x = 0;
	if (!gClassNameTable) return NULL;
	for(x = 0; x < gClassNameTableCount; ++x) {
		if (strcmp(name, gClassNameTable[x].name) == 0) {
			return gClassNameTable[x].classObject;
		}
	}
	return NULL;
}

// We don't know how to get at the real list of classes the MWObjC writes to the executable,
// so we have this function to allow manually doing it.
void objc_registerClass(Class theClass) {
	if (!gClassNameTable) {
		gClassNameTable = (struct ClassNameEntry*) NewPtr(sizeof(struct ClassNameEntry));
		gClassNameTableCount = 1;
	} else {
		++gClassNameTableCount;
		SetPtrSize((Ptr)gClassNameTable, sizeof(struct ClassNameEntry) * gClassNameTableCount);
	}
	gClassNameTable[gClassNameTableCount - 1].classObject = theClass;
	BlockMoveData(theClass->name, gClassNameTable[gClassNameTableCount - 1].name, strlen(theClass->name) + 1);
}

#if __MC68K__

extern asm id objc_msgSend(id argself,SEL op, ...)
{
	move.l	8(sp),-(sp)		//	push sel
	move.l	8(sp),-(sp)		//	push argself
	jsr		find_method_implementation
	addq.l	#8,sp
	move.l	a0,d0
	beq.s	L1
	jmp		(a0)
L1:	rts
}

extern asm id objc_msgSend_stret(void *result,id argself,SEL op, ...)
{
	move.l	12(sp),-(sp)		//	push sel
	move.l	12(sp),-(sp)		//	push argself
	jsr		find_method_implementation
	addq.l	#8,sp
	move.l	a0,d0
	beq.s	L1
	jmp		(a0)
L1:	rts
}

extern asm id objc_msgSendSuper(objc_super *argsuper, SEL op, ...)
{
	move.l	8(sp),-(sp)		//	push sel
	move.l	8(sp),-(sp)		//	push argsuper
	jsr		find_super_implementation
	addq.l	#8,sp
	move.l	a0,d0
	beq.s	L1
	move.l	4(sp),a1		//	replace argsuper with self
	move.l	(a1),4(sp)
	jmp		(a0)
L1:	rts
}

extern asm id objc_msgSend_stretSuper(void *result,objc_super *argsuper, SEL op, ...)
{
	move.l	12(sp),-(sp)	//	push sel
	move.l	12(sp),-(sp)	//	push argsuper
	jsr		find_super_implementation
	addq.l	#8,sp
	move.l	a0,d0
	beq.s	L1
	move.l	8(sp),a1		//	replace argsuper with self
	move.l	(a1),8(sp)
	jmp		(a0)
L1:	rts
}

#endif
