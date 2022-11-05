#include <stdlib.h>

typedef  int 			(*_compare_function_context)(const void*, const void*, void*);  /* mm 961031 */ /* cc 042400 */

_MSL_IMP_EXP_C void  	qsort_context(void*, size_t, size_t, _compare_function_context, void*);                      /* mm 961031 */
