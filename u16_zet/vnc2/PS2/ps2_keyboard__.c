 
 #include <string.h>
 #include "ps2_keyboard.h"
 
 #define ERROR(x)

 void message(char *msg);
 void number(unsigned char val);


 unsigned char Fkeys []   = {	0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7}; //F-Keys

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

  
	message("ST_0 kb_buf: ");
	for (i = 0; i < 8; i++) {
		number(KBHID_buff[i]);
	}
    message(eol);
	
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
	for (i=0; i<8; i++){
		if(LIN_BUF_curr[i] == LIN_BUF_prev[i]) {
			RESET_BIT(&pPS2_keyboard->press,   i); 
			RESET_BIT(&pPS2_keyboard->release, i);
		} else if (LIN_BUF_prev[i] == Fkeys [i]){
			RESET_BIT(&pPS2_keyboard->press,   i); 
		} else if (LIN_BUF_curr[i] == Fkeys [i]){
			RESET_BIT(&pPS2_keyboard->release, i); 
		}
	}

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

unsigned char USB_PS2_bkp(unsigned char USB_code)
{
	unsigned char PS2_code;
	switch(USB_code) 
	{
       case 0xE0 : // Left  Ctrl //====================
       {
			PS2_code = 0x14;
         break;
       }
	   case 0xE1 : // Left shift  (CAPS SHIFT)
       {
			PS2_code = 0x12;
         break;
       }
	   case 0xE2 : // Left  Alt
       {
			PS2_code = 0x11;
         break;
       }
	   case 0xE3 : // Left  GUI -- RESET 
       {
			PS2_code = 0x1F; //==========
         break;
       }
       case 0xE4 : // CTRL (Symbol Shift)
       {
			PS2_code = 0x14; //==========
         break;
       }
	   case 0xE5 : // Right shift (SYMB SHIFT)
       {
			PS2_code = 0x59;
		 break;
	   }
	   case 0xE6 : // Right Alt
       {
			PS2_code = 0x11; //===========
		 break;
	   }	   
	   case 0xE7 : // -- Right GUI
       {
			PS2_code = 0x27; //===========
		 break;
	   }
	   //=================================
		case 0x28 : // -- ENTER
		{
			PS2_code = 0x5a;
		 break;
		}
       //--------------------------------
		case 0x1d : // -- Z
		{
			PS2_code = 0x1a;
		 break;
		}
		case 0x1b : // -- X
		{
			PS2_code = 0x22;
		 break;
		}
		case 0x06 : // -- C
		{
			PS2_code = 0x21;
		 break;
		}
		case 0x19 : // -- V
		{
			PS2_code = 0x2a;
		break;
		}
        //-----------------
		case 0x04 : // -- A
		{
			PS2_code = 0x1c;
		break;
		}
		case 0x16 : // -- S
		{
			PS2_code = 0x1b;
		break;
		}
		case 0x07 : // -- D
		{
			PS2_code = 0x23;
		break;
		}
		case 0x09 : // -- F
		{
			PS2_code = 0x2b;
		break;
		}
		case 0x0a : // -- G
		{
			PS2_code = 0x34;
		break;
		}
		//------------------
		case 0x14 : // -- Q
		{
			PS2_code = 0x15;
		break;
		}
		case 0x1a : // -- W
		{
			PS2_code = 0x1d; 
		break;
		}
		case 0x08 : // -- E
		{
			PS2_code = 0x24; 
		break;
		}
		case 0x15 : // -- R
		{
			PS2_code = 0x2d; 
		break;
		}
		case 0x17 : // -- T
		{
			PS2_code = 0x2c; 
		break;
		}
		//------------------
		case 0x1e : // -- 1
		{
			PS2_code = 0x16; 
		break;
		}
		case 0x1f : // -- 2
		{
			PS2_code = 0x1e; 
		break;
		}
		case 0x20 : // -- 3
		{
			PS2_code = 0x26; 
		break;
		}
		case 0x21 : // -- 4
		{
			PS2_code = 0x25; 
		break;
		}
		case 0x22 : // -- 5
		{
			PS2_code = 0x2e; 
		break;
		}
		//------------------
		case 0x23 : // -- 6
		{
			PS2_code = 0x36; 
		break;
		case 0x24 : // -- 7
		{
			PS2_code = 0x3d; 
		break;
		case 0x25 : // -- 8
		{
			PS2_code = 0x3e; 
		break;
		case 0x26 : // -- 9
		{
			PS2_code = 0x46; 
		break;
		}
		case 0x27 : // -- 0
		{
			PS2_code = 0x45; 
		break;
		}
		//------------------

	    //================================
	    default:
		 PS2_code = 0x00;
	}
	return PS2_code;
}