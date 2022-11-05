#include "runtime.h"

EXTERN_C struct NSDictionaryImpl *NSDictionaryImplNew(void);
EXTERN_C void NSDictionaryImplFree(struct NSDictionaryImpl *dict);
EXTERN_C struct NSDictionaryImpl *NSDictionaryImplNewCopy(struct NSDictionaryImpl *dict);
EXTERN_C void NSDictionaryImplSetObjectForKey(struct NSDictionaryImpl *dict, id obj, const char* key);
EXTERN_C void NSDictionaryImplRemoveObjectForKey(struct NSDictionaryImpl *dict, const char* key);
EXTERN_C id NSDictionaryImplGetObjectForKey(struct NSDictionaryImpl *dict, const char* key);

EXTERN_C struct NSDictionaryImplIterator *NSDictionaryImplEnumeratorNew(struct NSDictionaryImpl *dict);
EXTERN_C void NSDictionaryImplEnumeratorFree(struct NSDictionaryImplIterator *itty);
EXTERN_C const char* NSDictionaryImplEnumeratorNextKey(struct NSDictionaryImplIterator *itty);
EXTERN_C id NSDictionaryImplEnumeratorNextObject(struct NSDictionaryImplIterator *itty);
