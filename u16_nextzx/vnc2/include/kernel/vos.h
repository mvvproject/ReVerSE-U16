/*
** vos.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II VOS kernel
**
** Author: FTDI
** Project: Vinculum II Kernel
** Module: Vinculum II Kernel
** Requires:
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __vos_h__
#define __vos_h__

#define VOS_VERSION_STRING "2.0.2"

#define NULL			   0
#define TRUE			   1
#define FALSE			   0

#define uint8			   unsigned char
#define int8			   char
#define int16			   short
#define uint16			   unsigned short
#define uint32			   unsigned int
#define pvoid			   unsigned char *

typedef uint8 (*PF)(uint8);
typedef void (*PF_OPEN)(void *);
typedef void (*PF_CLOSE)(void *);
typedef uint8 (*PF_IOCTL)(pvoid);
typedef uint8 (*PF_IO)(uint8 *, unsigned short, unsigned short *);
typedef void (*PF_INT)(void);

typedef void (*fnVoidPtr)(void);

#define VOS_ENTER_CRITICAL_SECTION asm {SETI; };
#define VOS_EXIT_CRITICAL_SECTION  asm {CLRI; }

// *******************************************************************
// VOS INITIALISATION
// *******************************************************************

// VOS initialisation and start-up
void vos_init(uint8 quantum, uint16 tick_cnt, uint8 num_devices);
void vos_start_scheduler(void);

// default interval for timer interrupts
#define VOS_TICK_INTERVAL 1

// default time-slice quantum for tasks in RUNNING state
#define VOS_QUANTUM		  50

// *******************************************************************
// THREADS
// *******************************************************************

// thread states
enum {
    IDLE,
    BLOCKED,
    READY,
    RUNNING,
    DELAYED,
    GONE
};

// thread structure definition
typedef struct _vos_tcb_t {
    struct _vos_tcb_t *next;
    uint8			  state;
    uint8			  orig_priority;
    uint8			  priority;
    uint8			  quantum;
    uint16			  delay;
    uint16			  sp;
    uint32			  eax;
    uint32			  ebx;
    uint32			  ecx;
    uint32			  r0;
    uint32			  r1;
    uint32			  r2;
    uint32			  r3;
    void			  *system_data;
    void			  *system_profiler;
    uint16			  flags;
    void			  *semaphore_list;
} vos_tcb_t;

vos_tcb_t *vos_create_thread(uint8 priority, uint16 stack, fnVoidPtr function, int16 arg_size, pack ...);
vos_tcb_t *vos_create_thread_ex(uint8 priority, uint16 stack, fnVoidPtr function, char *name, int16 arg_size, pack ...);

void vos_set_idle_thread_tcb_size(uint16 tcb_size);
vos_tcb_t *vos_get_idle_thread_tcb(void);

uint8 vos_delay_msecs(uint16 ms);
void vos_delay_cancel(vos_tcb_t *tcb);

// *******************************************************************
// MUTEXES
// *******************************************************************

// mutex states
#define VOS_MUTEX_UNLOCKED 0
#define VOS_MUTEX_LOCKED   1

// mutex attribute byte definitions
#define VOS_MUTEX_STATE	   (1 << 0)
#define VOS_MUTEX_PIP	   (1 << 1)
#define VOS_MUTEX_PCP	   (1 << 2)

// mutex type definition
typedef struct _vos_mutex_t {
    vos_tcb_t *threads;                // list of threads blocked on mutex
    vos_tcb_t *owner;                  // thread that has locked mutex
    uint8	  attr;                    // attribute byte
    uint8	  ceiling;                 // priority for priority ceiling protocol
} vos_mutex_t;

#define LOCKED(m)	   ((m)->attr & VOS_MUTEX_LOCKED)
#define PIP_ENABLED(m) ((m)->attr & VOS_MUTEX_PIP)
#define PCP_ENABLED(m) ((m)->attr & VOS_MUTEX_PCP)

void vos_init_mutex(vos_mutex_t *m, uint8 state);
void vos_lock_mutex(vos_mutex_t *m);
uint8 vos_trylock_mutex(vos_mutex_t *m);
void vos_unlock_mutex(vos_mutex_t *m);
uint8 vos_get_priority_ceiling(vos_mutex_t *m);
void vos_set_priority_ceiling(vos_mutex_t *m, uint8 priority);

// *******************************************************************
// SEMAPHORES
// *******************************************************************

// semaphore type definition
typedef struct _vos_semaphore_t {
    int16	  val;
    vos_tcb_t *threads;
    int8	  usage_count;
} vos_semaphore_t;

// semaphore list type definition
typedef struct _vos_semaphore_list_t {
    struct _vos_semaphore_list_t *next;
    int8						 siz;
    uint8						 flags;
    uint8						 result;
    vos_semaphore_t				 *list[1];
} vos_semaphore_list_t;

#define VOS_SEMAPHORE_FLAGS_WAIT_ALL (1 << 7)
#define VOS_SEMAPHORE_FLAGS_WAIT_ANY 0
#define VOS_SEMAPHORE_WAIT_ALL(l)  (((l)->flags & VOS_SEMAPHORE_FLAGS_WAIT_ALL) == 0x80)
#define VOS_SEMAPHORE_WAIT_ANY(l)  (((l)->flags & VOS_SEMAPHORE_FLAGS_WAIT_ALL) == 0)
#define VOS_SEMAPHORE_LIST_SIZE(n) ((sizeof(vos_semaphore_list_t) - sizeof(vos_semaphore_list_t *) + ((n) * sizeof(vos_semaphore_t *))))

void vos_init_semaphore(vos_semaphore_t *sem, int16 count);
void vos_wait_semaphore(vos_semaphore_t *s);
int8 vos_wait_semaphore_ex(vos_semaphore_list_t *l);
void vos_signal_semaphore(vos_semaphore_t *s);
void vos_signal_semaphore_from_isr(vos_semaphore_t *s);

// *******************************************************************
// CONDITION VARIABLES
// *******************************************************************
// condition variable type definition
typedef struct _vos_cond_var_t {
    vos_tcb_t	*threads;
    vos_mutex_t *lock;
    uint8		state;
} vos_cond_var_t;

void vos_init_cond_var(vos_cond_var_t *cv);
void vos_wait_cond_var(vos_cond_var_t *cv, vos_mutex_t *m);
void vos_signal_cond_var(vos_cond_var_t *cv);

// *******************************************************************
// DIAGNOSTICS
// *******************************************************************

uint16 vos_stack_usage(vos_tcb_t *tcb);
void vos_start_profiler(void);
void vos_stop_profiler(void);
uint32 vos_get_profile(vos_tcb_t *tcb);

typedef struct _vos_system_data_area_t {
    struct _vos_system_data_area_t *next;
    vos_tcb_t					   *tcb;
    uint32						   count;
    char						   *name;
} vos_system_data_area_t;

// *******************************************************************
// HARDWARE INFORMATION & CONTROL
// *******************************************************************

// System Clock
#define VOS_48MHZ_CLOCK_FREQUENCY 0
#define VOS_24MHZ_CLOCK_FREQUENCY 1
#define VOS_12MHZ_CLOCK_FREQUENCY 2

void vos_set_clock_frequency(uint8 frequency);
uint8 vos_get_clock_frequency(void);

// Package Type
#define VINCULUM_II_32_PIN 0
#define VINCULUM_II_48_PIN 1
#define VINCULUM_II_64_PIN 2

uint8 vos_get_package_type(void);

// Chip revision number
uint8 vos_get_chip_revision(void);

// Power Saving Mode
#define VOS_WAKE_ON_USB_0		0x01
#define VOS_WAKE_ON_USB_1		0x02
#define VOS_WAKE_ON_UART_RI		0x04
#define VOS_WAKE_ON_SPI_SLAVE_0 0x08
#define VOS_WAKE_ON_SPI_SLAVE_1 0x10

uint8 vos_power_down(uint8 wakeMask);

// Halt CPU
void vos_halt_cpu(void);

// Reset chip
void vos_reset_vnc2(void);

// Watchdog
// Watchdog enable return codes
#define VOS_WDT_STARTED			0x00
#define VOS_WDT_ALREADY_RUNNING 0x01
#define VOS_WDT_PENDING			0x02
#define VOS_WDT_UNSUPPORTED		0x03

uint8 vos_wdt_enable(uint8 bitPosition);
void vos_wdt_clear(void);

// Approximate millisecond timer functions
uint32 vos_get_kernel_clock(void);
void vos_reset_kernel_clock(void);

// *******************************************************************
// DEVICE MANAGER & KERNEL SERVICE INCLUDES
// *******************************************************************

#include "devman.h"
#include "dma.h"
#include "iomux.h"
#include "memmgmt.h"
#include "gpioctrl.h"

#endif

