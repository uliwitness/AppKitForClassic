/* 
	Modified to allow passing a context void*.
 */

/* Metrowerks Standard Library
 * Copyright © 1995-2001 Metrowerks Corporation.  All rights reserved.
 *
 * $Date: 2001/03/30 20:15:26 $
 * $Revision: 1.11 $
 */
 
/*
 *	Routines
 *	--------
 *		qsort
 *
 *	Implementation
 *	--------------
 *
 *		Here we use Heapsort, after Knuth's "The Art of Computer Programming, Vol. 3",
 *		Section 5.2.3. Heapsort was chosen because it requires no auxiliary storage and
 *		has excellent average *and* worst-case performance.
 *
 *	Future Enhancements
 *	-------------------
 *		
 *		Although this algorithm is theoretically efficient, it is not as efficient
 *		as it could be for certain special cases. Specifically, the Swap routine
 *		could be more efficient in the same way memcpy et al. could be, i.e., by
 *		moving longs instead of bytes whenever possible. This would only be
 *		beneficial with a large member_size, though.
 *		
 *		For smaller member_size's, many Swap operations could be eliminated
 *		entirely. We swap on each iteration through the 'sift' operation even
 *		though, in theory, we can pick up a value before the loop, put it in a
 *		temporary, and drop it in its final destination after the loop. Where we
 *		now swap in the loop, we would merely need to replace:
 *		
 *		   swap(ip,jp,member_size);
 *		
 *		with:
 *		
 *		   memcpy(ip,jp,member_size);
 *		
 *		which involves less work.
 *		
 *		We do the swap because we don't know, in general, how big a temporary we
 *		would be needing. We could conceivably malloc a temporary as needed and
 *		resort to the algorithm used here only when we can't get the memory
 *		needed. However, for reasonably small member_size's, say <= 64, we could
 *		use a statically allocated temporary.
 *		
 *		And finally, we can squeeze a lot of cycles for the special cases of
 *		member_size's of 1, 2, and 4 bytes, where we could presumably use a
 *		register for the temporary.
 *
 *
 *	18-Jul-95 JFH  First code release.
 *	04-Dec-95 JFH  Fixed small (!) bug in PPC version of swap. Was
 *								 pre-incrementing on store instead of fetch.
 */

#include "qsort_context.h"

#define table_ptr(i)	(((char *) table_base) + (member_size * ((i) - 1)))

#if !__POWERPC__

#define swap(dst, src, cnt)                                             \
do {                                                                    \
  char *  p;                                                            \
  char *  q;                                                            \
  size_t  n = cnt;                                                      \
                                                                        \
  unsigned char tmp;                                                    \
                                                                        \
  for (p = src, q = dst, n++; --n;)                                     \
  {                                                                     \
    tmp = *q;                                                           \
    *q++ = *p;                                                          \
    *p++ = tmp;                                                         \
  }                                                                     \
} while (0)
	
#else

#define swap(dst, src, cnt)                                             \
do {                                                                    \
  char *  p;                                                            \
  char *  q;                                                            \
  size_t  n = cnt;                                                      \
                                                                        \
  unsigned long tmp;                                                    \
                                                                        \
  for (p = (char *) src - 1, q = (char *) dst - 1, n++; --n;)     			\
  {                                                                     \
    tmp = *++q;                                                         \
    *q = *++p;                                                          \
    *p = tmp;                                                           \
  }                                                                     \
} while (0)

#endif

void qsort_context(void * table_base, size_t num_members, size_t member_size,
					 _compare_function_context compare_members, void* context)            /*- mm 961031 -*/
{
	size_t	l, r, /*i,*/ j;
	char *	lp;
	char *	rp;
	char *	ip;
	char *	jp;
	char *	kp;
	
	if (num_members < 2)
		return;
	
	r = num_members;
	l = (r / 2) + 1;
	
	lp = table_ptr(l);
	rp = table_ptr(r);
	
	for (;;)
	{
		if (l > 1)
		{
			l--;
			lp -= member_size;
		}
		else
		{
			swap(lp,rp,member_size);
			
			if (--r == 1)
				return;
				
			rp -= member_size;
		}
			
		j = l;
		
		jp = table_ptr(j);
		
		while (j*2 <= r)
		{
		/*i =  j;*/
			j *= 2;
			
			ip = jp;
			jp = table_ptr(j);
			
			if (j < r)
			{
				kp = jp + member_size;
				
				if (compare_members(jp, kp, context) < 0)
				{
					j++;
					jp = kp;
				}
			}
			
			if (compare_members(ip,jp,context) < 0)
				swap(ip,jp,member_size);	
			else
				break;
		}
	}
}

/* Change record:
 *	JFH 950718 First code release.
 *	JFH 951204 Fixed small (!) bug in PPC version of swap. Was
 *			   pre-incrementing on store instead of fetch.
 *  mm  961031 Improved legibility of function declaration
 */
