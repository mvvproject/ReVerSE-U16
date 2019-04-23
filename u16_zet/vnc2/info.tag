<?xml version="1.0"?>
<VinTag>
 <version>1.0.0</version>
 <file name="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
  <struct name="__unnamed_struct_1" line="18" file="PS2\ps2_keyboard.h">
   <member name="new_data" offset="0" size="8"
    basetype="CHAR" baseattr="unsigned,"/>
   <member name="usbkb_buf" offset="8" size="64"
    basetype="CHAR" baseattr="unsigned," basearray="8,"/>
   <member name="SW" offset="72" size="8"
    basetype="CHAR" baseattr="unsigned,"/>
   <member name="LIN_BUF_0" offset="80" size="112"
    basetype="CHAR" baseattr="unsigned," basearray="14,"/>
   <member name="LIN_BUF_1" offset="192" size="112"
    basetype="CHAR" baseattr="unsigned," basearray="14,"/>
   <member name="press" offset="304" size="16"
    basetype="SHORT" baseattr="unsigned,"/>
   <member name="release" offset="320" size="16"
    basetype="SHORT" baseattr="unsigned,"/>
  </struct>
  <struct name="PS2_keyboard_t" line="18" file="PS2\ps2_keyboard.h"    attr="" size="336">
   <member name="new_data" offset="0" size="8"
    basetype="CHAR" baseattr="unsigned,"/>
   <member name="usbkb_buf" offset="8" size="64"
    basetype="CHAR" baseattr="unsigned," basearray="8,"/>
   <member name="SW" offset="72" size="8"
    basetype="CHAR" baseattr="unsigned,"/>
   <member name="LIN_BUF_0" offset="80" size="112"
    basetype="CHAR" baseattr="unsigned," basearray="14,"/>
   <member name="LIN_BUF_1" offset="192" size="112"
    basetype="CHAR" baseattr="unsigned," basearray="14,"/>
   <member name="press" offset="304" size="16"
    basetype="SHORT" baseattr="unsigned,"/>
   <member name="release" offset="320" size="16"
    basetype="SHORT" baseattr="unsigned,"/>
  </struct>
  <typedef name="addr_t" line="20" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\config.h"
   basetype="SHORT" baseattr="signed,"/>
  <typedef name="size_t" line="19" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\config.h"
   basetype="SHORT" baseattr="signed,"/>
  <proto name="USB_PS2" line="213" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="CHAR" baseattr="unsigned,">
   <var name="USB_code" line="213" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="unsigned,"/>
  </proto>
  <proto name="SET_BIT" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="VOID" baseattr="">
   <var name="wBYTE" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="unsigned,ptr,"/>
   <var name="wBIT" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,"/>
  </proto>
  <proto name="KBParse" line="91" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="INT" baseattr="signed,">
   <var name="pPS2_keyboard" line="91" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basename="__unnamed_struct_1" basetype="STRUCT" baseattr="ptr,"/>
  </proto>
  <proto name="PS2_keyboard_init" line="83" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="VOID" baseattr="">
   <var name="pPS2_keyboard" line="83" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basename="__unnamed_struct_1" basetype="STRUCT" baseattr="ptr,"/>
  </proto>
  <proto name="CHECK_BIT" line="75" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="CHAR" baseattr="signed,">
   <var name="wBYTE" line="75" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="unsigned,"/>
   <var name="wBIT" line="75" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,"/>
  </proto>
  <proto name="RESET_BIT" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="VOID" baseattr="">
   <var name="wBYTE" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="unsigned,ptr,"/>
   <var name="wBIT" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,"/>
  </proto>
  <proto name="number" line="10" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="VOID" baseattr="">
   <var name="val" line="10" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="unsigned,"/>
  </proto>
  <proto name="memset" line="24" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="VOID" baseattr="ptr,">
   <var name="dstptr" line="24" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="VOID" baseattr="ptr,"/>
   <var name="value" line="24" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="INT" baseattr="signed,"/>
   <var name="num" line="24" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="signed,"/>
  </proto>
  <proto name="memcpy" line="23" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="VOID" baseattr="ptr,">
   <var name="destination" line="23" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="VOID" baseattr="ptr,"/>
   <var name="source" line="23" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="VOID" baseattr="const,ptr,"/>
   <var name="num" line="23" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="signed,"/>
  </proto>
  <proto name="strcat" line="29" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="CHAR" baseattr="signed,ptr,">
   <var name="destination" line="29" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,ptr,"/>
   <var name="source" line="29" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
  </proto>
  <proto name="strlen" line="30" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="SHORT" baseattr="signed,">
   <var name="str" line="30" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
  </proto>
  <proto name="strcmp" line="25" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="INT" baseattr="signed,">
   <var name="str1" line="25" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
   <var name="str2" line="25" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
  </proto>
  <proto name="strcpy" line="27" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="CHAR" baseattr="signed,ptr,">
   <var name="destination" line="27" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,ptr,"/>
   <var name="source" line="27" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
  </proto>
  <proto name="message" line="9" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   basetype="VOID" baseattr="">
   <var name="msg" line="9" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,ptr,"/>
  </proto>
  <proto name="strncmp" line="26" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="INT" baseattr="signed,">
   <var name="str1" line="26" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
   <var name="str2" line="26" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
   <var name="num" line="26" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="signed,"/>
  </proto>
  <proto name="strncpy" line="28" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
   basetype="CHAR" baseattr="signed,ptr,">
   <var name="destination" line="28" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="signed,ptr,"/>
   <var name="source" line="28" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="CHAR" baseattr="const,signed,ptr,"/>
   <var name="num" line="28" file="C:\ProgramData\FTDI\Vinculum II Toolchain\Firmware\C\include\string.h"
    type="AUTO" storage="AUTO VAR" attr="param,"
    basetype="SHORT" baseattr="signed,"/>
  </proto>
  <var name="Fkeys" line="13" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   type="AUTO" storage="AUTO VAR" attr="global,"
   basetype="CHAR" baseattr="unsigned," basearray="8,"/>
  <var name="USB_PS2_tb" line="16" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   type="AUTO" storage="AUTO VAR" attr="global,"
   basetype="CHAR" baseattr="unsigned," basearray="256,"/>
 <function name="SET_BIT" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c" 
  basetype="VOID" baseattr="">
  <var name="wBYTE" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   type="AUTO" storage="AUTO VAR" attr="param,"
   basetype="SHORT" baseattr="unsigned,ptr,"/>
  <var name="wBIT" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   type="AUTO" storage="AUTO VAR" attr="param,"
   basetype="CHAR" baseattr="signed,"/>
  <block line="66" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <var name="wBIT" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="CHAR" baseattr="signed,"/>
    <var name="wBYTE" line="65" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="SHORT" baseattr="unsigned,ptr,"/>
  </block>
 </function>
 <function name="RESET_BIT" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c" 
  basetype="VOID" baseattr="">
  <var name="wBYTE" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   type="AUTO" storage="AUTO VAR" attr="param,"
   basetype="SHORT" baseattr="unsigned,ptr,"/>
  <var name="wBIT" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
   type="AUTO" storage="AUTO VAR" attr="param,"
   basetype="CHAR" baseattr="signed,"/>
  <block line="71" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <var name="wBIT" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="CHAR" baseattr="signed,"/>
    <var name="wBYTE" line="70" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="SHORT" baseattr="unsigned,ptr,"/>
  </block>
 </function>
 <function name="CHECK_BIT" line="75" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c" 
  basetype="CHAR" baseattr="signed,">
  <block line="76" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <var name="wBIT" line="75" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="CHAR" baseattr="signed,"/>
    <var name="wBYTE" line="75" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="SHORT" baseattr="unsigned,"/>
  </block>
 </function>
 <function name="PS2_keyboard_init" line="83" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c" 
  basetype="VOID" baseattr="">
  <block line="84" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <var name="pPS2_keyboard" line="83" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basename="__unnamed_struct_1" basetype="STRUCT" baseattr="ptr,"/>
  </block>
 </function>
 <function name="KBParse" line="91" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c" 
  basetype="INT" baseattr="signed,">
  <block line="92" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <var name="eol" line="96" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="signed,ptr,"/>
    <var name="BUF" line="95" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="signed,"/>
    <var name="KBHID_buff" line="101" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="unsigned,ptr,"/>
    <var name="i" line="94" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="signed,"/>
    <var name="j" line="94" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="signed,"/>
    <var name="pPS2_keyboard" line="91" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basename="__unnamed_struct_1" basetype="STRUCT" baseattr="ptr,"/>
    <var name="LIN_BUF_curr" line="100" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="unsigned,ptr,"/>
    <var name="LIN_BUF_prev" line="99" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="unsigned,ptr,"/>
    <var name="Found" line="93" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="INT" baseattr="signed,"/>
   <block line="105" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
   </block>
   <block line="130" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <block line="131" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    </block>
    <block line="133" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    </block>
   </block>
   <block line="140" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <block line="141" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    </block>
   </block>
   <block line="152" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <block line="153" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
     <block line="154" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
     </block>
    </block>
   </block>
  </block>
 </function>
 <function name="USB_PS2" line="213" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c" 
  basetype="CHAR" baseattr="unsigned,">
  <block line="214" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c">
    <var name="PS2_code" line="215" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr=""
     basetype="CHAR" baseattr="unsigned,"/>
    <var name="USB_code" line="213" file="C:\Users\mvv\Desktop\VNC2 (ps2 keyboard mouse)\PS2\ps2_keyboard.c"
     type="AUTO" storage="AUTO VAR" attr="param,"
     basetype="CHAR" baseattr="unsigned,"/>
  </block>
 </function>
 </file>
</VinTag>
