/*
 * 2015.05.09 Based ON: 
 * ps2dev.h - a library to interface with ps2 hosts. See comments in
 * ps2.cpp.
 * Written by Chris J. Kiick, January 2008.
 * modified by Gene E. Scogin, August 2008.
 * Release into public domain.
 */


#include <vos.h>
#include "ps2dev.h"


#define LOW   0x0
#define HIGH  0x1
//since for the device side we are going to be in charge of the clock,
//the two defines below are how long each _phase_ of the clock cycle is
#define CLKFULL 40
// we make changes in the middle of a phase, this how long from the
// start of phase to the when we drive the data line
#define CLKHALF 20

char port_data;
char port_mode;

vos_mutex_t GPIO_Lock;

void PS2dev_init(void)
{
	port_mode = (0x1 << _led);                         // 0b00000100; OUTPUT
	port_data = 0b00000000;                            // 0b00000000; OFF
	vos_gpio_write_port     (GPIO_PORT_A, port_data);  //
	vos_gpio_set_port_mode	(GPIO_PORT_A, port_mode);  // A2 LED OUTPUT
	//--MUTEX
	vos_init_mutex(&GPIO_Lock, 1);					   // 1- VOS_MUTEX_LOCKED
}

void PS2dev_unlock(void)
{
	vos_unlock_mutex(&GPIO_Lock);
}


void LED_ON(void)
{
	vos_lock_mutex(&GPIO_Lock);
	port_data |= (0x01<<_led);
	vos_gpio_write_port (GPIO_PORT_A, port_data);
	vos_unlock_mutex(&GPIO_Lock);
}

void LED_OFF(void)
{
	vos_lock_mutex(&GPIO_Lock);
	port_data &= ~(0x01<<_led);
	vos_gpio_write_port (GPIO_PORT_A, port_data);
	vos_unlock_mutex(&GPIO_Lock);
}

void delayMicroseconds(int pin)
{

}

void golo(int pin)
{
	vos_lock_mutex(&GPIO_Lock);
	port_mode |= (0x01<<pin);
	vos_gpio_set_port_mode (GPIO_PORT_A, port_mode);
	vos_unlock_mutex(&GPIO_Lock);
}

void gohi(int pin)
{
	vos_lock_mutex(&GPIO_Lock);
	port_mode &= (~(0x01<<pin)); //RESET - HI
	vos_gpio_set_port_mode(GPIO_PORT_A, port_mode);
	vos_unlock_mutex(&GPIO_Lock);
}

char digitalRead (int pin)
{
	char data;
	vos_lock_mutex(&GPIO_Lock);
	vos_gpio_read_port(GPIO_PORT_A, &data);
	vos_unlock_mutex(&GPIO_Lock);
	data = (data >> pin) & 0x01 ;
	return data;
}

//====================================================================
//====================================================================

char PS2dev_host_req(void)
{
	if (digitalRead(_ps2clk) == LOW || digitalRead(_ps2data) == LOW) {
		return 1;
	} 
	else {
		return 0;
	}
}
	

char PS2dev_write(unsigned char data)
{
  unsigned char i;
  unsigned char parity = 1;

 /* if (digitalRead(_ps2clk) == HIGH && digitalRead(_ps2data) == HIGH) {
   delayMicroseconds(50);
  }*/
   
  if (digitalRead(_ps2clk) == LOW) {
    return -1;
  }

  if (digitalRead(_ps2data) == LOW) {
    return -2;
  }

  golo(_ps2data);
  delayMicroseconds(CLKHALF);

  //========CLK -LO =================
  if (digitalRead(_ps2clk) == LOW) {
    //return -1;
  }
  golo(_ps2clk);   // start bit
  //=================================
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  for (i=0; i < 8; i++)
  {
	if (data & 0x01)
	{
	  gohi(_ps2data);
	} else {
	  golo(_ps2data);
    }
    delayMicroseconds(CLKHALF);
    //========CLK -LO =================
	if (digitalRead(_ps2clk) == LOW) {
		//return -1;
	}
    golo(_ps2clk);   // start bit
    //================================= 
    delayMicroseconds(CLKFULL);
    gohi(_ps2clk);
    delayMicroseconds(CLKHALF);

    parity = parity ^ (data & 0x01);
    data = data >> 1;
  }
  // parity bit
  if (parity)
  {
    gohi(_ps2data);
  } else {
    golo(_ps2data);
  }
  delayMicroseconds(CLKHALF);
  //========CLK -LO =================
  if (digitalRead(_ps2clk) == LOW) {
    //return -1;
  }
  golo(_ps2clk);   // start bit
  //=================================  
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  // stop bit
  gohi(_ps2data);
  delayMicroseconds(CLKHALF);
  //========CLK -LO =================
  if (digitalRead(_ps2clk) == LOW) {
    //return -1;
  }
  golo(_ps2clk);   // start bit
  //=================================    
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  delayMicroseconds(100);
  return 0;
}

char PS2dev_write_c(unsigned char data)
{
  unsigned char i;
  unsigned char parity = 1;
  char err;

 /* if (digitalRead(_ps2clk) == HIGH && digitalRead(_ps2data) == HIGH) {
   delayMicroseconds(50);
  }*/

  err = 0;
   
  if (digitalRead(_ps2clk) == LOW) {
    return -1;
  }

  if (digitalRead(_ps2data) == LOW) {
    return -2;
  }
  
  //======START BIT =================
  golo(_ps2data);
  delayMicroseconds(CLKHALF);

  //========CLK -LO =================
  if (digitalRead(_ps2clk) == LOW) {
    return -1;
  }
  golo(_ps2clk);   // start bit
  //=================================
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  for (i=0; i < 8; i++)
  {
	if (data & 0x01)
	{
	  gohi(_ps2data);
	} else {
	  golo(_ps2data);
    }
    delayMicroseconds(CLKHALF);
    //========CLK -LO =================
	if (digitalRead(_ps2clk) == LOW) {
		return -1;
	}
    golo(_ps2clk);   // start bit
    //================================= 
    delayMicroseconds(CLKFULL);
    gohi(_ps2clk);
    delayMicroseconds(CLKHALF);

    parity = parity ^ (data & 0x01);
    data = data >> 1;
  }
  // parity bit
  if (parity)
  {
    gohi(_ps2data);
  } else {
    golo(_ps2data);
  }
  delayMicroseconds(CLKHALF);
  //========CLK -LO =================
  if (digitalRead(_ps2clk) == LOW) {
    return -1;
  }
  golo(_ps2clk);   // start bit
  //=================================  
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  // stop bit
  gohi(_ps2data);
  delayMicroseconds(CLKHALF);
  //========CLK -LO =================
  if (digitalRead(_ps2clk) == LOW) {
    return -1;
  }
  golo(_ps2clk);   // start bit
  //=================================    
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  delayMicroseconds(100);
  return 0;
}


char PS2dev_read(unsigned char * value)
{
  unsigned char data = 0x00;
  unsigned char i;
  unsigned char bit = 0x01;
  
  unsigned char parity = 1;
  
  //wait for data line to go low
  while (digitalRead(_ps2data) == HIGH) {
   if(digitalRead(_ps2clk) == HIGH){
      *value=0;
      return 0;
   }
  } 
  //wait for clock line to go high
  while (digitalRead(_ps2clk) == LOW) {

  } 
  delayMicroseconds(CLKHALF);
  golo(_ps2clk);
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);

  for (i=0; i < 8; i++)
    {
      if (digitalRead(_ps2data) == HIGH)
   {
     data = data | bit;
   } else {
      }


      bit = bit << 1;
      
      delayMicroseconds(CLKHALF);
      golo(_ps2clk);   
      delayMicroseconds(CLKFULL);
      gohi(_ps2clk);
      delayMicroseconds(CLKHALF);
      
      parity = parity ^ (data & 0x01);
    }
  // we do the delay at the end of the loop, so at this point we have
  // already done the delay for the parity bit

  // stop bit
  delayMicroseconds(CLKHALF);
  golo(_ps2clk);   
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);
  

  delayMicroseconds(CLKHALF);
  golo(_ps2data);
  golo(_ps2clk);   
  delayMicroseconds(CLKFULL);
  gohi(_ps2clk);
  delayMicroseconds(CLKHALF);
  gohi(_ps2data);

  delayMicroseconds(100);
  *value = data;
  
  return 0;
}

///////////////////////////// KB ////////////////////////////////////////////
char PS2KB_write(unsigned char data)
{
  unsigned char i;
  unsigned char parity = 1;

 /* if (digitalRead(_ps2clk) == HIGH && digitalRead(_ps2data) == HIGH) {
   delayMicroseconds(50);
  }*/
   
  if (digitalRead(_ps2kbclk) == LOW) {
    return -1;
  }

  if (digitalRead(_ps2kbdata) == LOW) {
    return -2;
  }

  golo(_ps2kbdata);
  delayMicroseconds(CLKHALF);

  //========CLK -LO =================
  //if (digitalRead(_ps2kbclk) == LOW) {
    //return -1;
  //}
  golo(_ps2kbclk);   // start bit
  //=================================
  delayMicroseconds(CLKFULL);
  gohi(_ps2kbclk);
  //delayMicroseconds(CLKHALF);

  for (i=0; i < 8; i++)
  {
	if (data & 0x01)
	{
	  gohi(_ps2kbdata);
	} else {
	  golo(_ps2kbdata);
    }
    //delayMicroseconds(CLKHALF);
    //========CLK -LO =================
	//if (digitalRead(_ps2kbclk) == LOW) {
		//return -1;
	//}
    golo(_ps2kbclk);   // start bit
    //================================= 
    delayMicroseconds(CLKFULL);
    gohi(_ps2kbclk);
    //delayMicroseconds(CLKHALF);

    parity = parity ^ (data & 0x01);
    data = data >> 1;
  }
  // parity bit
  if (parity)
  {
    gohi(_ps2kbdata);
  } else {
    golo(_ps2kbdata);
  }
  delayMicroseconds(CLKHALF);
  //========CLK -LO =================
  //if (digitalRead(_ps2kbclk) == LOW) {
    //return -1;
  //}
  golo(_ps2kbclk);   // start bit
  //=================================  
  delayMicroseconds(CLKFULL);
  gohi(_ps2kbclk);
  delayMicroseconds(CLKHALF);

  // stop bit
  gohi(_ps2kbdata);
  delayMicroseconds(CLKHALF);
  //========CLK -LO =================
  //if (digitalRead(_ps2kbclk) == LOW) {
    //return -1;
  //}
  golo(_ps2kbclk);   // start bit
  //=================================    
  delayMicroseconds(CLKFULL);
  gohi(_ps2kbclk);
  delayMicroseconds(CLKHALF);

  delayMicroseconds(100);
  return 0;
}