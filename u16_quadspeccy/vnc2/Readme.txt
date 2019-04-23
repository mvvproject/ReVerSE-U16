Build 20160818 By Alexey Spirkov:
!fixed, added string vos_iocell_set_config(26, 0, 0, 0, 1);

Build 20160813 By MVV:
+While packet is transferring pin 12 (PORT_A1) is in High state (needed to detect packet start)
+LED Blanking

---------------------------------------------------------------------------
-- (c) 2015 Alexey Spirkov
-- I am happy for anyone to use this for non-commercial use.
-- If my vhdl/c files are used commercially or otherwise sold,
-- please contact me for explicit permission at me _at_ alsp.net.
-- This applies for source and binary form and derived works.
---------------------------------------------------------------------------

This firmware allows using both VNC2 ports to connecting HID devices
Its produce:

Release version:
  - 9 bytes packets from standard HID devices with UART 115200 8n1 - TX (Pin 23) package:
    - 0 Byte - port id (most significant bit) and device kind (remaining 7 bits)
      - 0x02 - mouse
      - 0x04 - joystick
      - 0x06 - keyboard
      - xxxx - etc. according USB specification
    - 1 - 8 byte device report:

      - Keyboard:
          Byte 1: Keyboard modifier bits (SHIFT, ALT, CTRL etc)
             Bit 0 - LCtrl
             Bit 1 - LShift
             Bit 2 - LAlt
             Bit 3 - LGUI
             Bit 4 - RCtrl
             Bit 5 - RShift
             Bit 6 - RAlt
             Bit 7 - RGui
           Byte 2: reserved
           Byte 3-8: Up to six keyboard usage indexes representing the keys that are
              currently "pressed".
            Order is not important, a key is either pressed (present in the
            buffer) or not pressed.
            Scan codes defined in "USB HID Usage tables" document

       - Joystick (Actual for Defender Game Master G2):
          Byte 1 - 3: - not used
          Byte 4: - left/right state (0x00: left, 0x7f - middle, 0xff - right)
          Byte 5: - up/down state (0x00: up, 0x7f - middle, 0xff - down)
          Byte 6: - 1 - 4 buttons 
                    Bit 4: 1 Button, 
                    Bit 5: 2 Button, 
                    Bit 6: 3 Button, 
                    Bit 7: 4 Button
          Byte 7: - top buttons and 9, 10 buttons
                    Bit 0: L1 Button, 
                    Bit 1: R1 Button, 
                    Bit 2: L2 Button, 
                    Bit 3: R2 Button, 
                    Bit 4:  9 Button,
                    Bit 5: 10 Button
          Byte 8: - not used

       - Mouse:
          Byte 1:     Buttons
          Byte 2:     Left/Right delta
          Byte 3:     Up/Down delta
          Byte 4:     Wheel delta
          Byte 5 - 8: not used

  While packet is transferring pin 12 (PORT_A1) is in Low state (needed to detect packet start)

In debug version (make DEBUG=1) everything goes in printable format with the same UART speed
