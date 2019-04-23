# Radio-86RK FPGA replica on ReVerSE-U16 board

## Overview

This project is a **Radio-86RK** port of the original Altera DE1 FPGA implementation by Dmitry Tselikov aka **b2m** on *ReVerSE-U16 board*.

## Hardware part

This port is designed to run on **ReVerSE-U16 Rev.C** board with Cyclone IV (EP4CE22E22C8).

## Software part

To compile the project, you need at least Quartus II with Cyclone IV support.

To run confifuration automatially when board powering on, you need to perform the following steps:

1. Convert *sof*-firmware into *jic* using u16_rk86.cof convertor config;
2. Upload u16_rk86.jic via JTAG to the on-board EPCS16 serial flash memory.

### SD card usage

SD card should be formatted as _FAT16_ filesystem. Place _*.RK_ files anywhere on the SD card filesystem.
Pressing "U" and enter will run the SD card interface.
SD card interface is quiet simple, you just need to type "DIR" to get a list of files on SD card, "CD" to change directory and 
then type a filename to run, then press "Enter".

### Keyboard usage

* F1 - F1
* F2 - F2
* F3 - F3
* F4 - F4
* F5 - F5
* ЗБ - BackSpace
* ВК - Enter
* ПС - Scroll
* НЭ - Home
* УС - Ctrl
* CC - Shift
* СТР - Delete
* ТАБ - Tab
* АР2 - Esc
* Рус/Лат - Alt

## Useful links

* Forum discussion: http://zx-pk.ru/showthread.php?t=12985 
* More about Radio-86RK: https://ru.wikipedia.org/wiki/Радио_86РК
