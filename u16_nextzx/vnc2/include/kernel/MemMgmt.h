/*
** MemMgmt.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II Kernel Memory Management
**
** Author: FTDI
** Project: Vinculum II Kernel
** Module: Vinculum II Kernel Memory Management
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __MEMMGMT_H__
#define __MEMMGMT_H__

#define MEMMGMT_VERSION_STRING "2.0.2"

void *vos_malloc(unsigned short size);
void vos_free(void *ptrFree);
void *vos_memset(void *dstptr, int value, short num);
void *vos_memcpy(void *destination, const void *source, short num);

unsigned short vos_heap_size(void);
void vos_heap_space(unsigned short *hfree, unsigned short *hmax);

#endif
