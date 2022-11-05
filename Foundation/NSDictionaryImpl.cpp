#include "NSDictionaryImpl.h"
#include <map>
#include <string>

using namespace std;

struct NSObjectWrapper {
	NSObjectWrapper(id obj = nil) : _object(obj) { objc_retainObject(_object); }
	NSObjectWrapper(const NSObjectWrapper& original) : _object(original._object) { objc_retainObject(_object); }
	~NSObjectWrapper() { objc_releaseObject(_object); }
	
	NSObjectWrapper& operator = (id newObj) {
		id oldObj = _object;
		_object = objc_retainObject(newObj);
		objc_releaseObject(oldObj);
		return *this;
	}
	
	id _object;
};

struct NSDictionaryImplIterator {
	NSDictionaryImplIterator(map<string, NSObjectWrapper>::iterator itty, struct NSDictionaryImpl * owner) : _iterator(itty), _owner(owner) {}
	
	struct NSDictionaryImpl *_owner;
	map<string, NSObjectWrapper>::iterator _iterator;
};

struct NSDictionaryImpl {
	map<string, NSObjectWrapper> _map;
};

extern "C" struct NSDictionaryImpl *NSDictionaryImplNew(void) {
	return new NSDictionaryImpl;
}

extern "C" struct NSDictionaryImpl *NSDictionaryImplNewCopy(struct NSDictionaryImpl *dict) {
	struct NSDictionaryImpl *result = new NSDictionaryImpl;
	result->_map = dict->_map;
	return result;
}

extern "C" void NSDictionaryImplFree(struct NSDictionaryImpl *dict) {
	delete dict;
}

extern "C" void NSDictionaryImplSetObjectForKey(struct NSDictionaryImpl *dict, id obj, const char* key) {
	dict->_map[string(key)] = obj;
}

extern "C" void NSDictionaryImplRemoveObjectForKey(struct NSDictionaryImpl *dict, const char* key) {
	map<string, NSObjectWrapper>::iterator foundObject = dict->_map.find(string(key));
	if (foundObject != dict->_map.end()) {
		dict->_map.erase(foundObject);
	}
}

extern "C" id NSDictionaryImplGetObjectForKey(struct NSDictionaryImpl *dict, const char* key) {
	return dict->_map[string(key)]._object;
}

extern "C" struct NSDictionaryImplIterator *NSDictionaryImplEnumeratorNew(struct NSDictionaryImpl *dict) {
	return new struct NSDictionaryImplIterator(dict->_map.begin(), dict);
}

extern "C" void NSDictionaryImplEnumeratorFree(struct NSDictionaryImplIterator *itty) {
	delete itty;
}

extern "C" const char* NSDictionaryImplEnumeratorNextKey(struct NSDictionaryImplIterator *itty) {
	const char* result = NULL;
	if (itty->_iterator != itty->_owner->_map.end()) {
		result = itty->_iterator->first.c_str();
		++itty->_iterator;
	}
	return result;
}

extern "C" id NSDictionaryImplEnumeratorNextObject(struct NSDictionaryImplIterator *itty) {
	id result = nil;
	if (itty->_iterator != itty->_owner->_map.end()) {
		result = itty->_iterator->second._object;
		++itty->_iterator;
	}
	return result;
}


