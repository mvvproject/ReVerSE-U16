#include <vos.h>
#include "ps2dev.h"
#include "ps2_mouse.h"


//================START==============================
void PS2_mouse_init(PS2_mouse_t* PS2_mouse) {
	PS2_mouse->conected = 0;
	PS2_mouse->Button	= 0;
	PS2_mouse->Xpos		= 0;
	PS2_mouse->Ypos		= 0;
	PS2_mouse->Wheel	= 0;
	//------------------------
	PS2_mouse->StreamMode = 1;
	PS2_mouse->DataRepEN  = 0;
	PS2_mouse->new_data   = 0;
	PS2_mouse->Resolution = 0;
	PS2_mouse->SampleRate = 20;

}

//ack a host command
void ack() {
  while(PS2dev_write(0xFA)!=0);
}

char MS_wr_packet(PS2_mouse_t* PS2_mouse) {
  char overflowx =0;
  char overflowy =0;
  char data[3];

  /* 
  if (PS2_mouse->Xpos > 255) {
    overflowx =1;
    PS2_mouse->Xpos = 255;
  }
  if (PS2_mouse->Xpos < -255) {
    overflowx = 1;
    PS2_mouse->Xpos = -255;
  }  
  if (PS2_mouse->Ypos > 255) {
    overflowy =1;
    PS2_mouse->Ypos = 255;
  }
  if (PS2_mouse->Ypos  < -255) {
    overflowy = 1;
    PS2_mouse->Ypos =-255;
  }
 */

  PS2_mouse->Ypos = (~PS2_mouse->Ypos);
  PS2_mouse->Ypos ++;
	
  data[0] = ((0 & 1)                << 7) |
    (        (0 & 1)                << 6) |
    ( ((( PS2_mouse->Ypos & 0x100)>>8) & 1) << 5) |  // Ypos Sign
    ( ( ((PS2_mouse->Xpos & 0x100)>>8) & 1) << 4) |  // Xpos Sign
    (                                  ( 1) << 3) |  //
    ( ( (PS2_mouse->Button>>2) & 1)         << 2) |  // BOT 2
    ( ( (PS2_mouse->Button>>1) & 1)         << 1) |  // BOT 1
    ( ( (PS2_mouse->Button>>0) & 1)         << 0) ;  // BOT 0
    
  data[1] = PS2_mouse->Xpos & 0xff;
  data[2] = PS2_mouse->Ypos & 0xff;
	
  /*	
  data[0] = ((0 & 1)                        << 7) |
    (        (0 & 1)                        << 6) |
    ( ((( 0x100 & 0x100)>>8) & 1) << 5) |
    ( ( ((0x100 & 0x100)>>8) & 1) << 4) |
    (                                  ( 1) << 3) |
    ( ( (PS2_mouse->Button>>2) & 1)         << 2) |
    ( ( (PS2_mouse->Button>>1) & 1)         << 1) |
    ( ( (PS2_mouse->Button>>0) & 1)         << 0) ;
    
  data[1] = 1  & 0xff;
  data[2] = 1  & 0xff;	
  */
  
  //PS2dev_write(data[0]);
  //vos_delay_msecs(1);
  //PS2dev_write(data[1]);
  //vos_delay_msecs(1);	
  //PS2dev_write(data[2]);
  //vos_delay_msecs(1);
	
  if(PS2dev_write_c(data[0])!=0){
	return -1;
  }
  //vos_delay_msecs(1);

  if(PS2dev_write_c(data[1])!=0){
	return -1;
  }
  //vos_delay_msecs(1);
  
  if(PS2dev_write_c(data[2])!=0){
	return -1;
  }
  //vos_delay_msecs(1);
	

return 0;
}


void MS_cmd(unsigned char command, PS2_mouse_t* PS2_mouse) {
  unsigned char val;

  //This implements enough mouse commands to get by, most of them are
  //just acked without really doing anything

  switch (command) {
  case 0xFF: //reset
    ack();
    //the while loop lets us wait for the host to be ready
    //PS2_mouse_init (PS2_mouse);
    while(PS2dev_write(0xAA)!=0);  
    while(PS2dev_write(0x00)!=0);
  
    break;
  case 0xFE: //resend
    //ack();  
    MS_cmd(PS2_mouse->PrevCMD, PS2_mouse); //RESEND AGAIN Host received wrong data
    break;
  case 0xF6: //set defaults 
    //enter stream mode 
	PS2_mouse->StreamMode = 1;
    ack();
    break;
  case 0xF5:  //disable data reporting
    PS2_mouse->DataRepEN  = 0;
    ack();
    break;
  case 0xF4: //enable data reporting
	PS2_mouse->DataRepEN  = 1;
    ack();
    break;
  case 0xF3: //set sample rate
    ack();
    PS2dev_read(&val); // for now drop the new rate on the floor
    ack();
	PS2_mouse->SampleRate = val; // надо запомнить, что от нас хочет хост
    break;
  case 0xF2: //get device id
    ack();
    while(PS2dev_write(0x00)!=0);
    break;
  case 0xF0: //set remote mode
//	PS2_mouse->DataRepEN  = 0;
	PS2_mouse->StreamMode = 0;
    ack();  
    break;
  case 0xEE: //set wrap mode
    ack();
    break;
  case 0xEC: //reset wrap mode
    ack();
    break;
  case 0xEB: //read data
    ack();
    MS_wr_packet(PS2_mouse);
    break;
  case 0xEA: //set stream mode
	PS2_mouse->StreamMode = 1;
    ack();
    break;
  case 0xE9: //status request
    ack();
    while(PS2dev_write(0xE6)!=0);					// ƒаем инфу о настройках мыши 
    while(PS2dev_write(PS2_mouse->Resolution)!=0);  // и если потребуетс€ запомненные от хоста параметры,
    while(PS2dev_write(PS2_mouse->SampleRate)!=0);	// если тот проверить захочет
    //      send_status();
    break;
  case 0xE8: //set resolution
    ack();
    PS2dev_read(&val);
    ack();
	PS2_mouse->Resolution = val; 
    break;
  case 0xE7: //set scaling 2:1
    ack();
    break;
  case 0xE6: //set scaling 1:1
    ack();
    break;
  case 0x0: // “акой команды нет, но есть така€ заглушка, ответа не требуетс€ 
    break;
  default: // ¬ообще на любую команду нужен ответ
    ack();
  } 
  if(command!=0xfe){ //NOT RESEND AGAIN, so copy current comand
    PS2_mouse->PrevCMD = command;
  }
}


