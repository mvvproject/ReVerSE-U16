/*
** DMA.h
**
** Copyright © 2009-2011 Future Technology Devices International Limited
**
** Header file containing definitions for Vinculum II Kernel DMA management and control
**
** Author: FTDI
** Project: Vinculum II Kernel
** Module: Vinculum II Kernel DMA Control
** Requires: vos.h
** Comments:
**
** History:
**  1 – Initial version
**
*/

#ifndef __DMA_H__
#define __DMA_H__

#define DMA_VERSION_STRING "2.0.2"

#define vos_dma_handle_t   uint16

// DMA status definitions
enum dma_status {
    DMA_OK = 0,
    DMA_INVALID_PARAMETER,
    DMA_ACQUIRE_ERROR,
    DMA_ENABLE_ERROR,
    DMA_DISABLE_ERROR,
    DMA_CONFIGURE_ERROR,
    DMA_ERROR,
    DMA_FIFO_ERROR
};

// dma_config_t
typedef struct _vos_dma_config_t {
    union
    {
        uint16 io_addr;
        uint8  *mem_addr;
    } src;
    union
    {
        uint16 io_addr;
        uint8  *mem_addr;
    }	   dest;
    uint16 bufsiz;
    uint8  mode;
    uint8  fifosize;
    uint8  flow_control;
    uint8  afull_trigger;
} vos_dma_config_t;

#define DMA_FLOW_CONTROL_DIF		0x00
#define DMA_FLOW_CONTROL_UART		0x10
#define DMA_FLOW_CONTROL_FPROG		0x20
#define DMA_FLOW_CONTROL_SPISLAVE_1 0x30
#define DMA_FLOW_CONTROL_SPISLAVE_0 0x40
#define DMA_FLOW_CONTROL_SPI_MASTER 0x50
#define DMA_FLOW_CONTROL_FIFO		0x60
#define DMA_FLOW_CONTROL_DMA_1		0x70
#define DMA_FLOW_CONTROL_DMA_2		0x80
#define DMA_FLOW_CONTROL_DMA_3		0x90
#define DMA_FLOW_CONTROL_DMA_4		0xA0

#define DMA_MODE_PUSH				0x00
#define DMA_MODE_PULL				0x10
#define DMA_MODE_MEM_COPY			0x20
#define DMA_MODE_FIFO				0x30

vos_dma_handle_t vos_dma_acquire(void);
void vos_dma_release(vos_dma_handle_t h);
uint8 vos_dma_reset(vos_dma_handle_t h);
uint8 vos_dma_configure(vos_dma_handle_t h, vos_dma_config_t *cb);
uint8 vos_dma_retained_configure(vos_dma_handle_t h, uint8 *mem_addr, uint16 bufsiz);
uint8 vos_dma_enable(vos_dma_handle_t h);
uint8 vos_dma_disable(vos_dma_handle_t h);
void vos_dma_wait_on_complete(vos_dma_handle_t h);
uint16 vos_dma_get_fifo_data_register(vos_dma_handle_t h);
uint8 vos_dma_get_fifo_flow_control(vos_dma_handle_t h);
uint16 vos_dma_get_fifo_count(vos_dma_handle_t h);
uint8 vos_dma_get_fifo_data(vos_dma_handle_t h, uint8 *dat);

#endif
