wlink name Zbios d all sys dos com OPTION quiet, NOFARCALLS , MAP OUTPUT raw offset=0xf0000 ORDER clname DATA segment _DATA segaddr=0xf000 offset=0xe500 clname CODE segment _TEXT segaddr=0xf000 offset=0xeA00 segment _BIOSSEG segaddr=0xf000 offset=0xF800 disable 1014 op m  op maxe=25 op q op symf FIL {entry.obj zetbios.obj} libf clibs.lib

