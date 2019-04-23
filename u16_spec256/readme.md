#### SPEC256
![image](pic1.jpg) ![image](pic2.jpg)

SPEC256: http://www.emulatronia.com/emusdaqui/spec256/download-eng.htm

игры: http://www.emulatronia.com/emusdaqui/spec256/download-eng.htm

редактор: http://kolmck.net/apps/EmuZ/EmuZWin_Rus.htm

Демонстрационное видео:

[![Spec256 on FPGA (ReVerSE-U16)](http://img.youtube.com/vi/0wNCMqNwaIU/0.jpg)](http://www.youtube.com/watch?feature=player_embedded&v=0wNCMqNwaIU)

[![ReVerSE-U16 FPGA SoftCore - Spec256 (build 20170604)](http://img.youtube.com/vi/5JCH4aDUbvE/0.jpg)](https://www.youtube.com/watch?v=5JCH4aDUbvE)

build 20171015:
- добавлена поддержка Gamepad "Game Master G2"
- bright 0 для бордюра
- F1 Joystick on/off

build 20170604:
- 1 CPU GFX_Z80 вместо восьми T80
- F2 = режим 256c

build 20160819:
- Video HDMI 640x480@60Hz
- F5 = MENU для загрузки игр
- VNC2 обновлена прошивка
- работают не все игры, требуется правильная адаптация

build 20160629:
- HDMI Audio

build 20160621:
- загрузка игры из SPIFLASH с адреса 0x000B4000 = CYBERNOI.SNA, 0x000C001B = CYBERNOI.GFX
- 8 CPU T80@3.5MHz/7.0MHz
- ROM 16K
- RAM 48K
- Video HDMI 720x480@60Hz
- SDRAM
- USB Keyboard
- F4 = Reset, F5 = NMI
- Sound Beeper (Delta-sigma stereo) порт #FE выведен на разъем uBus(X10)
- исправил encoder, на многих мониторах не работал HDMI
