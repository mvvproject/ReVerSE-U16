//-----------------------------------------------------------------[22.05.2015]
// 22.05.2015	MVV		//Bit 7=1 указывает на префикс 0xE0, добавлены: 0x00=Overrun Error, 0x80=POST Fail, 0x7f=None. Исправлен код Caps Lock

 #include <string.h>
 #include "ps2_keyboard.h"
 
 #define ERROR(x)

 void message(char *msg);
 void number(unsigned char val);


unsigned char Fkeys []   = {	0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7}; // F-Keys

//Bit 7=1 указывает на префикс 0xE0, 0x00=Overrun Error, 0x80=POST Fail, 0x7f=None
unsigned char USB_PS2_tb [] ={	0x7f, 0x00, 0x80, 0x7f, 0x1c, 0x32, 0x21, 0x23, 
								0x24, 0x2b, 0x34, 0x33, 0x43, 0x3b, 0x42, 0x4b,
								//0x10
								0x3a, 0x31, 0x44, 0x4d, 0x15, 0x2d, 0x1b, 0x2c, 
								0x3c, 0x2a, 0x1d, 0x22, 0x35, 0x1a, 0x16, 0x1e,
								//0x20
								0x26, 0x25, 0x2e, 0x36, 0x3d, 0x3e, 0x46, 0x45, 
								0x5a, 0x76, 0x66, 0x0d, 0x29, 0x4e, 0x55, 0x54,
								//0x30
								0x5b, 0x5d, 0x5d, 0x4c, 0x52, 0x0e, 0x41, 0x49, 
								0x4a, 0x58, 0x05, 0x06, 0x04, 0x0c, 0x03, 0x0b, 
								//0x40---
								0x83, 0x0a, 0x01, 0x09, 0x78, 0x07, 0xfc, 0x7e,  // Print Screen
								0xf7, 0xf0, 0xec, 0xfd, 0xf1, 0xe9, 0xfa, 0xf4,  // Break
								//0x50---
								0xeb, 0xf2, 0xf5, 0x77, 0xca, 0x7c, 0x7b, 0x79,
								0x1a, 0x69, 0x72, 0x7a, 0x6b, 0x73, 0x74, 0x6c,
								//0x60---
								0x75, 0x7d, 0x70, 0x71, 0x61, 0xaf, 0x7f, 0x0f,
								0x2f, 0x37, 0x3f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0x70---
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0x80 =======================================
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x6d, 0x7f, 0x51,
								0x13, 0x6a, 0x64, 0x67, 0x27, 0x7f, 0x7f, 0x7f,
								//0x90
								0x7f, 0x7f, 0x63, 0x62, 0x5f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0xA0
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0xB0
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0xC0
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0xD0
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0xE0
								0x14, 0x12, 0x11, 0x9f, 0x94, 0x59, 0x91, 0xa7,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								//0xF0
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f,
								0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f
							};

 void SET_BIT(unsigned short* wBYTE, char wBIT)
 {
	*wBYTE  |=  (0x01<< wBIT);
 }

 void RESET_BIT(unsigned short* wBYTE, char wBIT)
 {
	*wBYTE  &= ~(0x01<< wBIT);
 }

 char CHECK_BIT(unsigned short  wBYTE, char wBIT)
 {
	 wBYTE = (wBYTE >> wBIT) & 0x01 ;
	 return (char)wBYTE; 

 }

 
  void PS2_keyboard_init(PS2_keyboard_t* pPS2_keyboard)
 {
	pPS2_keyboard->SW = 0x0;
	memset(pPS2_keyboard->LIN_BUF_0, 0x0, 14 * sizeof(char));
	memset(pPS2_keyboard->LIN_BUF_1, 0x0, 14 * sizeof(char));
 }

 //====================KB PARSER==================================
 int KBParse(PS2_keyboard_t* pPS2_keyboard)
 {
    int Found;
    char i,j;
    char BUF;
	char *eol = "\r\n";
     //===========================

   unsigned char *  LIN_BUF_prev;
   unsigned char *  LIN_BUF_curr;
   unsigned char*   KBHID_buff;

   KBHID_buff = pPS2_keyboard->usbkb_buf; 

   if (pPS2_keyboard->SW == 0x0){
		pPS2_keyboard->SW = 0x1;
		LIN_BUF_curr = pPS2_keyboard->LIN_BUF_1;
		LIN_BUF_prev = pPS2_keyboard->LIN_BUF_0;
   } else {
		pPS2_keyboard->SW = 0x0;
	 	LIN_BUF_curr = pPS2_keyboard->LIN_BUF_0;
		LIN_BUF_prev = pPS2_keyboard->LIN_BUF_1;
   }


   pPS2_keyboard->press   = 0x3FFF;      //check_press   <= "00111111 11111111";
   pPS2_keyboard->release = 0x3FFF;

    /*
	message("ST_0 kb_buf: ");
	for (i = 0; i < 8; i++) {
		number(KBHID_buff[i]);
	}
    message(eol);
	*/
	
    // STEP_1 ===============================================================================================
        for (i=0; i<8; i++){
		if (KBHID_buff[0] & (1<< i)) {
			LIN_BUF_curr[i] = Fkeys [i];
		} else {
			LIN_BUF_curr[i] = 0x0;
		}
	}
	memcpy(&LIN_BUF_curr[8], &KBHID_buff[2], 6);

    // Step_2 ===============================================================================================
//	for (i=0; i<8; i++){
//		if(LIN_BUF_curr[i] == LIN_BUF_prev[i]) {
//			RESET_BIT(&pPS2_keyboard->press,   i); 
//			RESET_BIT(&pPS2_keyboard->release, i);
//		} else if (LIN_BUF_prev[i] == Fkeys [i]){
//			RESET_BIT(&pPS2_keyboard->press,   i); 
//		} else if (LIN_BUF_curr[i] == Fkeys [i]){
//			RESET_BIT(&pPS2_keyboard->release, i); 
//		}
//	}

	// ST_3 Check Press =======================================================================================
	for (j=0; j<6; j++){
		for (i=0; i<6; i++){
			if(LIN_BUF_curr[8+j] == LIN_BUF_prev[8+i]) {
				RESET_BIT(&pPS2_keyboard->press,   8+j); //SW_1 - what is not pressed
				RESET_BIT(&pPS2_keyboard->release, 8+i); //SW_2 - what is not released
			}
		}
	}

	
	//=============================MSG===========
	/*
	message("buf_curr: ");
	for (i = 0; i < 14; i++) {
		number(LIN_BUF_curr[i]);
	}
    message(eol);
	
	message("buf_prev: ");
	for (i = 0; i < 14; i++) {
		number(LIN_BUF_prev[i]);
	}
    message(eol);
	
	message("press: ");
	BUF = pPS2_keyboard->press>>8 & 0xFF;
	number (BUF);
	BUF = pPS2_keyboard->press & 0xFF;
	number (BUF);
	message(eol);
	
	message("release: ");
	BUF = pPS2_keyboard->release>>8 & 0xFF;
	number (BUF);
	BUF = pPS2_keyboard->release & 0xFF;
	number (BUF);
	message(eol);
	*/
    //=============================================
	
	/*
	// ST_4 Check Release =====================================================================================
	for (i=0; i<14; i++){
		if (CHECK_BIT(pKB_parcer->release, i)){
			BUF = 0xF0;    // Break
			// Convert Table here
			BUF = USB_PS2(pKB_parcer->DB_LIN_BUFF[pKB_parcer->SW_2][i]);
		}
	}
    
	// ST_5 Press
	for (i=0; i<14; i++){
		if (CHECK_BIT(pKB_parcer->press, i)){
			// Convert Table here
			BUF = USB_PS2(pKB_parcer->DB_LIN_BUFF[pKB_parcer->SW_1][i]);
		}
	}
	*/

   return Found;
 }

unsigned char USB_PS2(unsigned char USB_code)
{
	unsigned char PS2_code;

	PS2_code = USB_PS2_tb [USB_code];
	return PS2_code;
}
