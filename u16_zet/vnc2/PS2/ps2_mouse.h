
#ifndef ps2_mouse_h
#define ps2_mouse_h


typedef struct _PS2_mouse_t
{
  uchar             conected;
  //--------------------------
  uchar				new_data;
  uchar				Button;             
  unsigned short	Xpos;
  unsigned short	Ypos;
  unsigned short	Wheel;
  //---Conditions==============
  unsigned char		StreamMode;
  unsigned char		DataRepEN ;
  unsigned char		Resolution;
  unsigned char		SampleRate;
  //==========================
  unsigned char		PrevCMD;

} PS2_mouse_t;

void PS2_mouse_init(PS2_mouse_t* PS2_mouse);
void MS_cmd(unsigned char command, PS2_mouse_t* PS2_mouse);
char MS_wr_packet(PS2_mouse_t* PS2_mouse);

#endif 
/* ps2_mouse_h */

