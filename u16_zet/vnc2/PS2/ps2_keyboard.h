 
 /* -------------------------------------------------------------------------- */
 
 #ifndef ps2_keyboard_H
 #define ps2_keyboard_H

 typedef struct //KB_parcer ===========
 {
   unsigned char   new_data;
   unsigned char   usbkb_buf[8];
   //-------------------------------------
   unsigned char   SW;
   unsigned char   LIN_BUF_0 [14];
   unsigned char   LIN_BUF_1 [14];
   //----------------------------------
   unsigned short  press;
   unsigned short  release;
 } PS2_keyboard_t;
 
 char CHECK_BIT(unsigned short  wBYTE, char wBIT);
 void PS2_keyboard_init(PS2_keyboard_t* pPS2_keyboard);
 int KBParse(PS2_keyboard_t* PS2_keyboard);
 unsigned char USB_PS2(unsigned char USB_code);

 
 #endif

