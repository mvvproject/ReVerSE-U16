#### Lo-tech 2MB EMS Board

The driver is a patched version of original works Copyright (c) 1988, Alex Tsourikov.

#### Licensing

Original source kindly provided subject to the [http://opensource.org/licenses/BSD-3-Clause BSD 3-Clause]. This software, as modified, is provided subject to the Standard Lo-tech License [http://www.lo-tech.co.uk/wiki/lo-tech.co.uk:General_disclaimer].

#### Coding Changes

The Lo-tech card differs from the BOCARAM clone board for which Alex's driver was originally written in three ways:

*EMS pages are numbered 0..127 (compared to 128..255)
*Page Registers are addresses consecutively, by default 260h to 263h (compared to being spaced by 4000h)
*Page Registers cannot be read

#### Usage

LTEMM.EXE should be installed through CONFIG.SYS in the usual way (tested on MS-DOS 6.22):

 Syntax:    DEVICE=LTEMM.EXE [/switches]
  /p:nnnn - Page frame address (E000)
  /i:nnn  - EMS i/o port base address (260)
  /h:nnn  - Maximal number of handles (64)
  /d:nn   - Depth of contest saves (5)
  /f:nnn  - First page number (0)
  /n      - Bypass memory test
  /x      - Perform long memory test
  /3      - Use only EMS 3.2 functions
  /q      - Quiet mode
 
 Defaults in parentheses.

Where the card is configured to be operating at E000h and 260h, no parameters are needed.

#### LIM4 Support

The driver supports all LIM4 EMS functions, except:

*Function 19 (non-volatile handles)
*Function 28 (alternate registers - software support only)

#### Downloads
[http://www.lo-tech.co.uk/wiki/LTEMM.EXE]
