wlink name Zbios sys dos OPTION quiet OPTION NOFARCALLS OPTION FILLCHAR=0xFF OPTION NOFARCALLS, MAP OUTPUT raw offset=0xf0000 ORDER clname DATA segment _DATA segaddr=0xf000 offset=0xe500 clname CODE segment _TEXT segaddr=0xf000 offset=0xeA00 segment _BIOSSEG segaddr=0xf000 offset=0xF800 disable 1014 LIBRARY clibs.lib FILE {entry.obj zetbios.obj}  

