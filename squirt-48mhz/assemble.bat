@echo off
D:
cd D:\Xilinx\14.7\ISE_DS
call settings64.bat
D:
cd "D:\Xbox 360 Fast\Timing Working\RGH1.2-V2-Slim\squirt-48mhz"
xst -intstyle ise -ifn "D:/Xbox 360 Fast/Timing Working/RGH1.2-V2-Slim/squirt-48mhz/overall.xst" -ofn "D:/Xbox 360 Fast/Timing Working/RGH1.2-V2-Slim/squirt-48mhz/overall.syr"
ngdbuild -intstyle ise -dd _ngo -uc main.ucf -p xc2c64a-CP56-7 "overall.ngc" overall.ngd
cpldfit -intstyle ise -p xc2c64a-7-CP56 -ofmt vhdl -optimize density -htmlrpt -loc on -slew fast -init low -exhaust -inputs 25 -pterms 20 -unused keeper -terminate keeper -iostd LVCMOS18 overall.ngd
hprep6 -s IEEE1149 -i overall
impact -batch assemble-impact.cmd