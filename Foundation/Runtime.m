#include	"Runtime.h"#include	"NSAutoreleasePool.h"#import		<stdlib.h>#import		<string.h>static IMP find_method_implementation(id receiver,SEL sel){	if(receiver!=nil)	{		Class		isa;		const char	*selector_name;		selector_name=(const char *)sel;		for(isa=receiver->isa; isa; isa=isa->super_class)		{			objc_method_list	*mlist;			int					i,n;				if((mlist=isa->methodlist)!=NULL)			{				for(i=0,n=mlist->method_count; i<n; i++)				{					if(strcmp(selector_name,mlist->method_list[i].method_name)==0)					{						return mlist->method_list[i].method_imp;					}				}			}		}	}	return NULL;}static IMP find_super_implementation(objc_super *argsuper,SEL sel){	id receiver;	receiver=argsuper->receiver;	if(receiver!=nil)	{		Class		isa;		const char	*selector_name;		selector_name=(const char *)sel;		for(isa=receiver->isa; isa; isa=isa->super_class)		{			if(isa->isa==argsuper->mclass) break;		}		for(; isa; isa=isa->super_class)		{			objc_method_list	*mlist;			int					i,n;				if((mlist=isa->methodlist)!=NULL)			{				for(i=0,n=mlist->method_count; i<n; i++)				{					if(strcmp(selector_name,mlist->method_list[i].method_name)==0)					{						return mlist->method_list[i].method_imp;					}				}			}		}	}	return NULL;}@implementation MWObject+alloc{	NSObject*	newobj;	newobj = (NSObject*)malloc(((Class)self)->instance_size);	//	allocate instance object	memset(newobj,0,((Class)self)->instance_size);		//	clear instance object	newobj->isa = (Class)self;							//	initialize isa member	return newobj;}-(void)dealloc{	free(self);}-init{	//	nothing to initialize	return self;}-(id)retain{	return self;}-(void)release{}-(id) autorelease{	return self;}-(BOOL)conformsTo:(Protocol *)protocol{	objc_protocol_list	*plist;	Class				cls;	long				i;	for(cls=self->isa; cls; cls=cls->super_class)	{		if((plist=cls->protocols)!=NULL)		{			for(i=0; i<plist->count; i++)			{				if([plist->list[i] conformsTo:protocol]) return YES;			}		}	}	return NO;}- performSelector:(SEL)aSelector{	return ((id(*)(id,SEL))objc_msgSend)(self,aSelector);}- performSelector:(SEL)aSelector withObject: (id)arg1{	return ((id(*)(id,SEL,id))objc_msgSend)(self, aSelector, arg1);}-(BOOL) respondsToSelector: (SEL)aSelector{	return find_method_implementation(self, aSelector) != NULL;}+(BOOL) respondsToSelector: (SEL)aSelector{	return find_method_implementation(self, aSelector) != NULL;}+(Class) class{	return self;}-(Class) class{	return isa;}@end@implementation NSObject+alloc{	NSObject *newobj = [super alloc];	newobj->_referenceCount = 1;	return newobj;}-(id)retain{	++self->_referenceCount; // TODO: Make thread-safe.	return self;}-(void)release{	if( (--self->_referenceCount) == 0 ) {		[self dealloc];	} }-(id) autorelease{	[gCurrentPool addObject: self];	return self;}@end@implementation Protocol- (const char *)name{	return protocol_name;}- (BOOL) conformsTo:(Protocol *)protocol{	objc_protocol_list	*plist;	long				i;	if(strcmp([self name],[protocol name])==0) return YES;	if((plist=self->protocol_list)!=NULL)	{		for(i=0; i<plist->count; i++)		{			if([plist->list[i] conformsTo:protocol]) return YES;		}	}	return NO;}@end#if __MC68K__extern asm id objc_msgSend(id argself,SEL op, ...){	move.l	8(sp),-(sp)		//	push sel	move.l	8(sp),-(sp)		//	push argself	jsr		find_method_implementation	addq.l	#8,sp	move.l	a0,d0	beq.s	L1	jmp		(a0)L1:	rts}extern asm id objc_msgSend_stret(void *result,id argself,SEL op, ...){	move.l	12(sp),-(sp)		//	push sel	move.l	12(sp),-(sp)		//	push argself	jsr		find_method_implementation	addq.l	#8,sp	move.l	a0,d0	beq.s	L1	jmp		(a0)L1:	rts}extern asm id objc_msgSendSuper(objc_super *argsuper, SEL op, ...){	move.l	8(sp),-(sp)		//	push sel	move.l	8(sp),-(sp)		//	push argsuper	jsr		find_super_implementation	addq.l	#8,sp	move.l	a0,d0	beq.s	L1	move.l	4(sp),a1		//	replace argsuper with self	move.l	(a1),4(sp)	jmp		(a0)L1:	rts}extern asm id objc_msgSend_stretSuper(void *result,objc_super *argsuper, SEL op, ...){	move.l	12(sp),-(sp)	//	push sel	move.l	12(sp),-(sp)	//	push argsuper	jsr		find_super_implementation	addq.l	#8,sp	move.l	a0,d0	beq.s	L1	move.l	8(sp),a1		//	replace argsuper with self	move.l	(a1),8(sp)	jmp		(a0)L1:	rts}#endif