#!/usr/bin/env bash

set -e
export WRK_DIR=../bin/working
export PATH=$(pwd)/../linuxtools/:${PATH}

BUILD_TYPE=${BUILD_TYPE:-std}


mkdir -p ${WRK_DIR}
rm -f ${WRK_DIR}/*.mac
rm -f ${WRK_DIR}/*.h
sf "kernel/M80.CPM" "M80.COM"
sf "kernel/L80.CPM" "L80.COM"
sf "kernel/LIB80.CPM" "LIB80.COM"
sf "Makefile-main.mk" "Makefile"
sf -s kernel bank.inc const.inc macros.inc
sf "kernel/*.mac"
sf "kernel/bank0/*.mac"
sf "kernel/bank1/*.mac"
sf "kernel/bank2/*.mac"
sf "kernel/bank3/*.mac"
sf kernel/bank4/dskab.mac dskab4.mac
sf kernel/bank4/dskab.mac dskab4.mac
sf kernel/bank4/misc.mac misc4.mac
sf kernel/bank4/ramdrv.mac ramdrv4.mac
sf kernel/bank4/seg.mac seg4.mac
sf -s kernel/bank4 ramdrvh.mac env.mac b4.mac time.mac cpm.mac jump.mac partit.mac
  # 40ff.mac and doshead.mac bkalloc.mac in bank4 are not used???
sf "kernel/bank5/*.mac"
sf "kernel/bank5/*.s"
sf "kernel/bank5/*.c"
sf "kernel/bank5/*.h"
sf "kernel/bank6/*.mac"
sf kernel/drivers/SunriseIDE/chgbnk.mac srchgbnk.mac
sf kernel/drivers/SunriseIDE/driver.mac sunrise.mac
sf "kernel/drivers/rc2014/*.mac"
sf "kernel/drivers/rc2014/sio.inc"
sf kernel/drivers/StandaloneASCII16/chgbnk.mac a6chgbnk.mac
sf kernel/drivers/yellowmsxforrc2014/ymchgbnk.mac
sf "common/*"
sf "command/msxdos/*.mac"
sf command/command/files.mac cmdfiles.mac
sf command/command/messages.mac cmdmsgs.mac
sf command/command/misc.mac cmdmisc.mac
sf command/command/ver.mac cmdver.mac
sf -s command/command start.mac cli.mac cmd.mac copy.mac dirs.mac io.mac jtext.mac var.mac command.inc
sf "command/chkdsk/main.mac"  main.mac
sf "command/chkdsk/text.mac"  text.mac
sf "command/chkdsk/jtext.mac" chjtext.mac
sf "command/chkdsk/var.mac" chvar.mac
sf "command/chkdsk/end.mac" chend.mac
sf "command/chkdsk/misc.mac" chmisc.mac
sf "command/chkdsk/nodebug.mac" nodebug.mac
sf "command/chkdsk/dir.mac" chdir.mac
sf "command/chkdsk/*.inc"
sf "command/fixdisk/fixdisk.mac"
sf "command/fixdisk/text.mac" fdtext.mac
sf "command/fixdisk/jtext.mac" fdjtext.mac
sf "tools/*.MAC"

rm -f ${WRK_DIR}/condasm.inc
sf "kernel/condasm/${BUILD_TYPE}.inc" condasm.inc
