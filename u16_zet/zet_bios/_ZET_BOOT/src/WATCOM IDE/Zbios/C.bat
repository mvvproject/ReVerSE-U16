wcc zetbios.c -i="C:\WATCOM/h" -1 -w3 -e25 -zu -s -ecc -ms -d2 -od -zq -bt=dos -fo=.obj
wcc zetbios.c -i="C:\WATCOM/h" -w3 -e25 -zq -ecc -od -d2 -zu -1 -bt=dos -fo=.obj -ms -s
wmake -f LINK.win zetbios.rom 