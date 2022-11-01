/*
	C-callable portions of our runtime.

	Parts extracted from the Metwowerks CodeWarrior Objective C mini
	runtime (MWObjC.h and MWObjC.m).
	©Copyright 1997 by metrowerks inc.
*/

#ifndef _OBJC_RUNTIME_H
#define _OBJC_RUNTIME_H

#if __cplusplus
#define EXTERN_C 	extern "C"
#else
#define EXTERN_C 	
#endif

// constants

#define YES		(BOOL)1
#define NO		(BOOL)0

#define Nil		((Class)0)
#define nil		((id)0)

// types

typedef struct objc_class *Class;
typedef struct objc_object {
	Class isa;
}	*id;

typedef struct objc_selector	*SEL;    
typedef char					*STR;
typedef id						(*IMP)(id, SEL, ...); 
typedef char					BOOL;

#if __OBJC__
@class Protocol;
#else
typedef struct Protocol Protocol;
#endif


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

// functions

EXTERN_C id objc_retainObject(id obj);
EXTERN_C void objc_releaseObject(id obj);
EXTERN_C id objc_autoreleaseObject(id obj);

#endif /* _OBJC_RUNTIME_H */