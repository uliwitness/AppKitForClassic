/************************************************************************/
/*	Project...:	CodeWarrior Objective C runtime							*/
/*	Name......:	MWObjC.h												*/
/*	Purpose...:	C++ specific runtime functions							*/
/*  Copyright.: ©Copyright 1997 by metrowerks inc						*/
/************************************************************************/

#ifndef _MWOBJC_H
#define _MWOBJC_H

#pragma objective_c on

//	defines

#define YES		(BOOL)1
#define NO		(BOOL)0

#define Nil		((Class)0)
#define nil		((id)0)

#define kClassIndexShift 		1
#define kClassIndexMask			0xfffeUL
#define kRetainCountShift		16
#define kRetainCountMask 		0xffff0000UL
#define kRetainCountInISABit	(1UL << 0)

#define RETAINCOUNT_FROM_ISA(n)	((((unsigned long)(n)) & kRetainCountMask) >> kRetainCountShift)
#define CLASS_INDEX_FROM_ISA(n)	((((unsigned long)(n)) & kClassIndexMask) >> kClassIndexShift)
#define ISA_FOR_INDEX_AND_REFCOUNT(idx, rc)	((void*)(kRetainCountInISABit | (((unsigned long)idx) << kClassIndexShift) | (((unsigned long)rc) << kRetainCountShift)))
//	typedefs

#define NSSelectorFromString(objCStr) ((SEL)[objCStr cString])

@class Protocol;

typedef struct objc_class *Class;
typedef struct objc_object {
	Class isa;
}	*id;

typedef struct objc_selector	*SEL;    
typedef char					*STR;
typedef id						(*IMP)(id, SEL, ...); 
typedef char					BOOL;

typedef struct objc_ivar_list {
	long ivar_count;
	struct objc_ivar {
		char *ivar_name;
		char *ivar_type;
		long ivar_offset;
	} ivar_list[1];			//	variable length structure
}	objc_ivar_list;

typedef struct objc_method_list {
	void	*obsolete;
	long	method_count;
	struct objc_method {
		char	*method_name;
		char	*method_types;
		IMP		method_imp;
	} method_list[1];			//	variable length structure
}	objc_method_list;

typedef struct objc_protocol_list {
	struct objc_protocol_list	*next;
	long						count;
	Protocol					*list[1];
}	objc_protocol_list;

struct objc_class {			
	Class				isa;	
	Class				super_class;	
	const char			*name;		
	long				version;
	long				info;
	long				instance_size;
	objc_ivar_list		*ivars;
	objc_method_list	*methodlist;
	void				*cache;
 	objc_protocol_list	*protocols;
};

typedef struct objc_super {
	id		receiver;
	Class	mclass;
}	objc_super;

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

-(BOOL)conformsTo:(Protocol *)protocol;
-(id) performSelector:(SEL)aSelector;
-(id) performSelector:(SEL)aSelector withObject: (id)arg1;

+(BOOL) respondsToSelector: (SEL)aSelector;
-(BOOL) respondsToSelector: (SEL)aSelector;

+(Class) class;
-(Class) class;

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

//	runtime functions
extern id objc_msgSend(id argself, SEL op, ...);
extern id objc_msgSendSuper(objc_super *argsuper, SEL op, ...);
extern id objc_msgSend_stret(void *result, id argself, SEL op, ...);
extern id objc_msgSend_stretSuper(void *result, objc_super *argsuper, SEL op, ...);

#if __cplusplus
}
#endif

#endif
