/*
	Minimal implementation of logging to a file when printf() is called.
*/

#ifndef __CONSOLE__
#include <console.h>
#endif

#include <stdio.h>
#include <string.h>

#include <Types.h>
#include <Memory.h>

/*
 *	extern short InstallConsole(short fd);
 *
 *	Installs the Console package, this function will be called right
 *	before any read or write to one of the standard streams.
 *
 *	short fd:		The stream which we are reading/writing to/from.
 *	returns short:	0 no error occurred, anything else error.
 */

short InstallConsole(short fd)
{
#pragma unused (fd)
	FILE* consoleFile = fopen(":console.txt", "w");
	fflush(consoleFile);
	fclose(consoleFile);

	return 0;
}

/*
 *	extern void RemoveConsole(void);
 *
 *	Removes the console package.  It is called after all other streams
 *	are closed and exit functions (installed by either atexit or _atexit)
 *	have been called.  Since there is no way to recover from an error,
 *	this function doesn't need to return any.
 */

void RemoveConsole(void)
{
}

/*
 *	extern long WriteCharsToConsole(char *buffer, long n);
 *
 *	Writes a stream of output to the Console window.  This function is
 *	called by write.
 *
 *	char *buffer:	Pointer to the buffer to be written.
 *	long n:			The length of the buffer to be written.
 *	returns short:	Actual number of characters written to the stream,
 *					-1 if an error occurred.
 */

long WriteCharsToConsole(char *buffer, long n)
{
	Str255 pstr;
	FILE* consoleFile = NULL;
	pstr[0] = n;
	BlockMoveData(buffer, pstr + 1, pstr[0]);
	DebugStr(pstr);
	
	consoleFile = fopen(":console.txt", "a");
	fwrite(buffer, 1, n, consoleFile);
	fflush(consoleFile);
	fclose(consoleFile);

	return 0;
}

/*
 *	extern long ReadCharsFromConsole(char *buffer, long n);
 *
 *	Reads from the Console into a buffer.  This function is called by
 *	read.
 *
 *	char *buffer:	Pointer to the buffer which will recieve the input.
 *	long n:			The maximum amount of characters to be read (size of
 *					buffer).
 *	returns short:	Actual number of characters read from the stream,
 *					-1 if an error occurred.
 */

long ReadCharsFromConsole(char *buffer, long n)
{
#pragma unused (buffer, n)

	return 0;
}

/*
 *	extern char *__ttyname(long fildes);
 *
 *	Return the name of the current terminal (only valid terminals are
 *	the standard stream (ie stdin, stdout, stderr).
 *
 *	long fildes:	The stream to query.
 *
 *	returns char*:	A pointer to static global data which contains a C string
 *					or NULL if the stream is not valid.
 */

extern char *__ttyname(long fildes)
{
#pragma unused (fildes)
	/* all streams have the same name */
	static char *__devicename = "null device";

	if (fildes >= 0 && fildes <= 2)
		return (__devicename);

	return (0L);
}

/* Begin mm 981218 */
/*
*
*    int kbhit()
*
*    returns true if any keyboard key is pressed without retrieving the key
*    used for stopping a loop by pressing any key
*/
int kbhit(void)
{
      return 0; 
}

/*
*
*    int getch()
*
*    returns the keyboard character pressed when an ascii key is pressed  
*    used for console style menu selections for immediate actions.
*/
int getch(void)
{
      return 0; 
}

/*
*     void clrscr()
*
*     clears screen
*/
void clrscr()
{
	FILE* consoleFile = NULL;
	const char* spacer = "\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r";
	DebugStr("\p\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r\r");
	consoleFile = fopen(":console.txt", "a");
	fwrite(spacer, 1, strlen(spacer), consoleFile);
	fflush(consoleFile);
	fclose(consoleFile);
}
