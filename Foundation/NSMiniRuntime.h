/*
	Parts extracted from the Metwowerks CodeWarrior Objective C mini
	runtime (MWObjC.h and MWObjC.m).
	©Copyright 1997 by metrowerks inc.
*/

#ifndef _NSMINIRUNTIME_H
#define _NSMINIRUNTIME_H

#pragma objective_c on

#define __OBJC__		1

#include "runtime.h"


// Stuff for accessing refcounts and Class pointers:
extern struct objc_class **gClasses;

#define kClassIndexShift 		1
#define kClassIndexMask			0x0000fffeUL
#define kRetainCountShift		16
#define kRetainCountMask 		0xffff0000UL
#define kRetainCountInISABit	(1UL << 0)

#define RETAINCOUNT_FROM_ISA(n)	((((unsigned long)(n)) & kRetainCountMask) >> kRetainCountShift)
#define CLASS_INDEX_FROM_ISA(n)	((((unsigned long)(n)) & kClassIndexMask) >> kClassIndexShift)
#define ISA_FOR_INDEX_AND_REFCOUNT(idx, rc)	((void*)(kRetainCountInISABit | (((unsigned long)idx) << kClassIndexShift) | (((unsigned long)rc) << kRetainCountShift)))
#define ISA_TO_PTR(isa) ((((unsigned long)(isa)) & kRetainCountInISABit) ? gClasses[CLASS_INDEX_FROM_ISA(isa)] : (isa))

// Standard functions:
#define NSSelectorFromString(objCStr) ((SEL)[objCStr cString])


@class NSString;

// Base class is also used for constant strings etc. for which MWObjC assumes a fixed layout with
// only an isa at the start, but we want it to implement no-ops for retain and release so we can
// use them everywhere without having to know they're constant. So we store the refcount and a
// class index in the isa. Since classes must be aligned, we use the low bit to indicate that an
// isa contains class index/refcount and is not constant. 
@interface NSObject
{
	Class	isa;				//	base class must have isa member
}

+(id)alloc;
-(void)dealloc;
-(id)init;

-(id)retain;
-(void)release;
-(id) autorelease;
-(unsigned) retainCount;

-(BOOL)conformsTo:(Protocol *)protocol;
-(id) performSelector:(SEL)aSelector;
-(id) performSelector:(SEL)aSelector withObject: (id)arg1;

+(BOOL) respondsToSelector: (SEL)aSelector;
-(BOOL) respondsToSelector: (SEL)aSelector;

-(id) valueForKey: (NSString*)ivarName;
-(void) setValue: (id)obj forKey: (NSString*)ivarName;

+(Class) class;
-(Class) class;

-(BOOL) isKindOfClass: (Class)aClass;

@end

@protocol NSObject

-(void)dealloc;
-(id)init;

-(id)retain;
-(void)release;
-(id) autorelease;

-(BOOL)conformsTo:(Protocol *)protocol;
-(id) performSelector:(SEL)aSelector;
-(id) performSelector:(SEL)aSelector withObject: (id)arg1;

-(BOOL) respondsToSelector: (SEL)aSelector;

-(Class) class;

-(BOOL) isKindOfClass: (Class)aClass;

@end

struct objc_method_description {
	SEL		name;
	char	*types;
};
struct objc_method_description_list {
	long		count;
	struct	objc_method_description list[1];
};

@interface Protocol : NSObject
{
@private
	char	*protocol_name;
 	struct	objc_protocol_list *protocol_list;
  	struct	objc_method_description_list *instance_methods, *class_methods; 
}
- (const char *)name;
- (BOOL) conformsTo:(Protocol *)protocol;
@end

extern Class objc_getClass(const char* name);
extern void objc_registerClass(Class theClass);


#if __cplusplus
extern "C" {
#endif

extern IMP find_method_implementation(id receiver,SEL sel);

//	runtime functions
extern id objc_msgSend(id argself, SEL op, ...);
extern id objc_msgSendSuper(objc_super *argsuper, SEL op, ...);
extern id objc_msgSend_stret(void *result, id argself, SEL op, ...);
extern id objc_msgSend_stretSuper(void *result, objc_super *argsuper, SEL op, ...);

#if __cplusplus
}
#endif

#endif /* _NSMINIRUNTIME_H_ */
