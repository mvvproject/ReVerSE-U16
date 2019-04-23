/*
 * 2015.05.09 Based ON: 
 * ps2dev.h - a library to interface with ps2 hosts. See comments in
 * ps2.cpp.
 * Written by Chris J. Kiick, January 2008.
 * modified by Gene E. Scogin, August 2008.
 * Release into public domain.
 */

#ifndef ps2dev_h
#define ps2dev_h

#include "vos.h"
#include "hidtypes.h"

#define _led     2 //pin #2
//====Mouse------------------
#define _ps2clk  4   //pin #4
#define _ps2data 5   //pin #5
//====Keyboard---------------
#define _ps2kbclk  6 //pin #6
#define _ps2kbdata 7 //pin #7




void  PS2dev_init    (void);
void  PS2dev_unlock  (void);
//-------MS---------------------------------
char  PS2dev_host_req(void);
char  PS2dev_write   (unsigned char data);
char  PS2dev_write_c (unsigned char data);
char  PS2dev_read    (unsigned char * data);
//-------KB---------------------------------
char  PS2KB_write	 (unsigned char data);
//-------LED -------------------------------
void LED_ON (void);
void LED_OFF(void);


#endif 
/* ps2dev_h */

