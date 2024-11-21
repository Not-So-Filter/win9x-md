@echo off

IF EXIST winbuilt.bin move /Y winbuilt.bin winbuilt.prev.bin >NUL

build_tools\asw -xx -q -A -L -U -E -i . main.asm
build_tools\p2bin -p=0 -z=0,uncompressed,Size_of_DAC_driver_guess,after main.p winbuilt.bin

del main.p

pause