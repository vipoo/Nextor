include Makefile-rules.mk

BLDDIR := ../bin/working/
VPATH = ../bin/working/

## Main targets

# --------------------------------------------------------------------------------------
# NEXTOR.SYS and NEXTORK.SYS

$(BLDDIR)nextor.hex: nokmsg.mac codes.rel data.rel reloc.rel ver.rel ref.rel sys.mac real.rel messages.rel end.rel
	@cd $(BLDDIR)
	ln -sf nokmsg.mac usekmsg.mac
	m80.sh sys.mac SYS
	l80.sh nextor.hex /P:100,CODES,DATA,RELOC,VER,REF,SYS,REAL,SYS,MESSAGES,END,NEXTOR/n/x/y/e

$(BLDDIR)nextor.sys: nextor.hex
	@cd $(BLDDIR)
	hex2bin -s 100 nextor.hex
	mv nextor.bin nextor.sys

$(BLDDIR)nextork.hex: yeskmsg.mac codes.rel data.rel reloc.rel ver.rel ref.rel sys.mac real.rel messages.rel kmsg.rel end.rel
	@cd $(BLDDIR)
	@ln -sf yeskmsg.mac usekmsg.mac
	m80.sh sys.mac SYS
	l80.sh nextork.hex /P:100,CODES,DATA,RELOC,VER,REF,SYS,REAL,SYS,MESSAGES,KMSG,END,NEXTORK/n/x/y/e

$(BLDDIR)nextork.sys: nextork.hex
	@cd $(BLDDIR)
	@hex2bin -s 100 nextork.hex
	mv nextork.bin nextork.sys

# --------------------------------------------------------------------------------------
# command2.com

$(BLDDIR)command2.hex: codes.rel data.rel start.rel cli.rel cmd.rel copy.rel dirs.rel cmdfiles.rel io.rel jtext.rel cmdmsgs.rel cmdmisc.rel var.rel ver.rel
	@cd $(BLDDIR)
	@l80.sh command2.hex /P:100,CODES,DATA,START,CLI,CMD,COPY,DIRS,CMDFILES,IO,JTEXT,CMDMSGS,CMDMISC,VAR,VER,COMMAND2/n/x/y/e

# --------------------------------------------------------------------------------------
# chkdsk.com

$(BLDDIR)chkdsk.hex: main.rel codes.rel text.rel chjtext.rel chvar.rel chend.rel chmisc.rel nodebug.rel ver.rel chdir.rel
	@cd $(BLDDIR)
	@l80.sh chkdsk.hex /P:100,CODES,TEXT,CHJTEXT,CHDIR,CHVAR,CHEND,MAIN,CHMISC,NODEBUG,VER,CHKDSK/N/X/Y/E


$(BLDDIR)fixdisk.hex: codes.rel ver.rel fixdisk.rel fdtext.rel fdjtext.rel end.rel
	@cd $(BLDDIR)
	@l80.sh fixdisk.hex /P:100,CODES,VER,FIXDISK,FDTEXT,FDJTEXT,END,FIXDISK/N/X/Y/E

# --------------------------------------------------------------------------------------
# TOOLS

TOOLS_LIST := drvinfo.com delall.com conclus.com drivers.com fastout.com lock.com mapdrv.com nsysver.com ralloc.com z80mode.com devinfo.com
.PHONY: tools
## Build tools binaries into the bin directory
tools: $(TOOLS_LIST)

TOOL_DEPS := codes.rel data.rel shared.rel
define buildtool =
	@cd $(BLDDIR)
	l80.sh $(notdir $@) /P:100,CODES,DATA,$(notdir $(basename $<)),SHARED,$(notdir $(basename $<))/N/X/Y/E
endef

$(BLDDIR)drvinfo.hex: $(TOOL_DEPS)
$(BLDDIR)devinfo.hex: $(TOOL_DEPS)
$(BLDDIR)delall.hex: $(TOOL_DEPS)
$(BLDDIR)conclus.hex: $(TOOL_DEPS)
$(BLDDIR)drivers.hex: $(TOOL_DEPS)
$(BLDDIR)fastout.hex: $(TOOL_DEPS)
$(BLDDIR)lock.hex: $(TOOL_DEPS)
$(BLDDIR)mapdrv.hex: $(TOOL_DEPS)
$(BLDDIR)nsysver.hex: $(TOOL_DEPS)
$(BLDDIR)ralloc.hex: $(TOOL_DEPS)
$(BLDDIR)z80mode.hex: $(TOOL_DEPS)

$(BLDDIR)%.hex: %.rel
	$(buildtool)

# --------------------------------------------------------------------------------------
# HARD DISK IMAGE

$(BLDDIR)hdd.dsk: nextor.sys command2.com fixdisk.com chkdsk.com $(TOOLS_LIST)
	@cd $(BLDDIR)
	sudo umount -df /media/hdddsk > /dev/null 2>&1 || true
	rm -f hdd.dsk
	mkfs.vfat -F 12 -C "hdd.dsk" 10000
	sudo mkdir -p /media/hdddsk
	sudo mount -t vfat hdd.dsk /media/hdddsk
	sudo cp -v --preserve=timestamps *.com /media/hdddsk
	sudo cp -v --preserve=timestamps nextor.sys /media/hdddsk
	sudo umount -df /media/hdddsk
	cp --preserve=timestamps hdd.dsk ../

## Build a FAT12 hard disk image containing nextor.sys, command2.com and all other tools
hdddsk: $(BLDDIR)hdd.dsk

# --------------------------------------------------------------------------------------
# BANK 0

$(BLDDIR)b0.hex: codes.rel kvar.rel data.rel rel.rel doshead.rel 40ff.rel b0.rel init.rel alloc.rel dskbasic.rel dosboot.rel bdos.rel ramdrv.rel chgbnk.rel drv.rel
	@cd $(BLDDIR)
	l80.sh b0.hex /p:4000,CODES,KVAR,DATA,REL,DOSHEAD,40FF,B0,INIT,ALLOC,DSKBASIC,DOSBOOT,BDOS,RAMDRV,/p:7700,drv,/p:7fd0,chgbnk,b0/n/x/y/e
	cleancpmfile.sh b0.sym

$(BLDDIR)b0.bin: b0.hex
	@cd $(BLDDIR)
	hex2bin -s 4000 b0.hex

$(BLDDIR)codes.rel:
$(BLDDIR)kvar.rel: macros.inc const.inc
$(BLDDIR)rel.rel:
$(BLDDIR)doshead.rel: macros.inc const.inc
$(BLDDIR)40ff:
$(BLDDIR)b0.rel: bank.inc
$(BLDDIR)init.rel: const.inc bank.inc
$(BLDDIR)alloc.rel:
$(BLDDIR)bdos.rel: macros.inc const.inc
$(BLDDIR)ramdrv.rel: macros.inc const.inc
$(BLDDIR)chgbnk.rel:

$(BLDDIR)b0labels.inc: b0.hex
	@cd $(BLDDIR)
	symtoequs.sh b0.sym b0labels.inc "\?\S*" DOSV0 GETERR BDOSE KDERR KABR

$(BLDDIR)b0lab_b3.inc: b0.hex
	@cd $(BLDDIR)
	symtoequs.sh b0.sym b0lab_b3.inc INIT TIMINT MAPBIO GWRK "R_\S*"

# --------------------------------------------------------------------------------------
# BANK 1

$(BLDDIR)b1.rel: b0labels.inc

$(BLDDIR)b1.hex: codes.rel kvar.rel data.rel b1.rel dosinit.rel mapinit.rel alloc.rel msg.rel chgbnk.rel
	@cd $(BLDDIR)
	l80.sh b1.hex /P:40FF,CODES,KVAR,DATA,B1,DOSINIT,MAPINIT,ALLOC,MSG,/p:7fd0,chgbnk,B1/N/X/Y/E

$(BLDDIR)b1.bin: b1.hex
	@cd $(BLDDIR)
	hex2bin -s 4000 b1.hex

# --------------------------------------------------------------------------------------
# BANK 2

$(BLDDIR)temp21.rel: char.rel dev.rel kbios.rel misc.rel seg.rel
	@cd $(BLDDIR)
	lib80.sh temp21.rel TEMP21=char.rel,dev.rel,kbios.rel,misc.rel,seg.rel/E

$(BLDDIR)temp22.rel: path.rel find.rel dir.rel handles.rel del.rel rw.rel files.rel
	@cd $(BLDDIR)
	lib80.sh TEMP22.rel TEMP22=path.rel,find.rel,dir.rel,handles.rel,del.rel,rw.rel,files.rel/E

$(BLDDIR)temp23.rel: buf.rel fat.rel val.rel err.rel
	@cd $(BLDDIR)
	lib80.sh temp23.rel TEMP23=buf.rel,fat.rel,val.rel,err.rel/E

$(BLDDIR)b2.rel: b0labels.inc

$(BLDDIR)b2.hex: temp21.rel temp22.rel temp23.rel codes.rel kvar.rel data.rel b2.rel kinit.rel chgbnk.rel
	@cd $(BLDDIR)
	l80.sh b2.hex /P:40FF,CODES,KVAR,DATA,B2,KINIT,TEMP21,TEMP22,TEMP23,/p:7fd0,chgbnk,B2/N/X/Y/E

$(BLDDIR)b2.bin: b2.hex
	@cd $(BLDDIR)
	rm -f b2.bin
	hex2bin -s 4000 b2.hex

$(BLDDIR)b2labels.inc: b2.hex
	@cd $(BLDDIR)
	symtoequs.sh b2.sym b2labels.inc "\?\S*"

# --------------------------------------------------------------------------------------
# BANK 3

$(BLDDIR)b3.rel: b0lab_b3.inc

$(BLDDIR)b3.hex: codes.rel kbdos.rel kvar.rel data.rel doshead.rel 40ff.rel dos1ker.rel b3.rel chgbnk.rel drv.rel
	@cd $(BLDDIR)
	l80.sh b3.hex /p:4000,CODES,KBDOS,KVAR,DATA,DOSHEAD,40FF,B3,DOS1KER,/p:7700,drv,/p:7fd0,chgbnk,b3/N/X/Y/E

$(BLDDIR)b3.bin: b3.hex
	@cd $(BLDDIR)
	rm -f b3.bin
	hex2bin -s 4000 b3.hex

# --------------------------------------------------------------------------------------
# BANK 4

$(BLDDIR)partit.rel: b0labels.inc

$(BLDDIR)b4.rel: b0labels.inc b2labels.inc

$(BLDDIR)b4.hex: codes.rel kvar.rel data.rel b4.rel jump.rel env.rel cpm.rel partit.rel ramdrv4.rel time.rel seg4.rel misc4.rel dskab4.rel chgbnk.rel
	@cd $(BLDDIR)
	l80.sh b4.hex /P:40FF,CODES,KVAR,DATA,B4,JUMP,ENV,CPM,PARTIT,RAMDRV4,TIME,SEG4,MISC4,/p:7bc0,DSKAB4,/p:7fd0,chgbnk,B4/N/X/Y/E

$(BLDDIR)b4.bin: b4.hex
	@cd $(BLDDIR)
	rm -f b4.bin
	hex2bin -s 4000 b4.hex

$(BLDDIR)b4rdlabs.inc: b4.hex
	@cd $(BLDDIR)
	symtoequs.sh b4.sym b4rdlabs.inc "R4_[1-9]"

$(BLDDIR)ramdrvh.rel: b4rdlabs.inc

$(BLDDIR)b4rd.hex: ramdrvh.rel
	@cd $(BLDDIR)
	l80.sh b4rd.hex /P:4080,RAMDRVH,B4RD/N/X/Y/E

$(BLDDIR)b4rd.bin: b4rd.hex
	@cd $(BLDDIR)
	hex2bin -s 4080 b4rd.hex

# --------------------------------------------------------------------------------------
# BANK 5

TOOLS_SRC := ./tools/C/

$(BLDDIR)b5.hex: codes.rel kvar.rel data.rel b5.rel chgbnk.rel
	@cd $(BLDDIR)
	l80.sh b5.hex /P:40FF,CODES,KVAR,DATA,B5,/p:7fd0,chgbnk,B5/N/X/Y/E

$(BLDDIR)b5.bin: b5.hex
	@cd $(BLDDIR)
	rm -f b5.bin
	hex2bin -s 4000 b5.hex

$(BLDDIR)fdisk.ihx: fdisk.c fdisk_crt0.rel fdisk.c $(TOOLS_SRC)AsmCall.h fdisk.h $(TOOLS_SRC)asm.h $(TOOLS_SRC)system.h $(TOOLS_SRC)dos.h $(TOOLS_SRC)types.h $(TOOLS_SRC)partit.h drivercall.h
	@cd $(BLDDIR)
	sdcc -DMAKEBUILD -I../../source/$(TOOLS_SRC) --code-loc 0x4120 --data-loc 0x8020 -mz80 --disable-warning 196 --disable-warning 84 --disable-warning 85 --max-allocs-per-node 10000 --allow-unsafe-read --opt-code-size --no-std-crt0 fdisk_crt0.rel fdisk.c

$(BLDDIR)fdisk.dat: fdisk.ihx
	@cd $(BLDDIR)
	hex2bin -e dat fdisk.ihx

$(BLDDIR)fdisk2.ihx: fdisk2.c fdisk_crt0.rel fdisk.c $(TOOLS_SRC)AsmCall.h fdisk.h $(TOOLS_SRC)asm.h $(TOOLS_SRC)system.h $(TOOLS_SRC)dos.h $(TOOLS_SRC)types.h $(TOOLS_SRC)partit.h drivercall.h
	@cd $(BLDDIR)
	sdcc -DMAKEBUILD -I../../source/$(TOOLS_SRC) --code-loc 0x4120 --data-loc 0xA000 -mz80 --disable-warning 196 --disable-warning 84 --disable-warning 85 --max-allocs-per-node 10000 --allow-unsafe-read --opt-code-size --no-std-crt0 fdisk_crt0.rel fdisk2.c

$(BLDDIR)fdisk2.dat: fdisk2.ihx
	@cd $(BLDDIR)
	hex2bin -e dat fdisk2.ihx

# --------------------------------------------------------------------------------------
# BANK 6

$(BLDDIR)b6.hex: codes.rel kvar.rel data.rel b6.rel chgbnk.rel
	@cd $(BLDDIR)
	l80.sh b6.hex /P:40FF,CODES,KVAR,DATA,B6,/p:7fd0,chgbnk,B6/N/X/Y/E

$(BLDDIR)b6.bin: b6.hex
	@cd $(BLDDIR)
	rm -f b6.bin
	hex2bin -s 4000 b6.hex

# --------------------------------------------------------------------------------------
# BASE IMAGE

$(BLDDIR)dos250ba.dat: b0.bin b1.bin b2.bin b3.bin b4.bin b5.bin b6.bin fdisk.dat fdisk2.dat b4rd.bin
	@cd $(BLDDIR)
	cat b0.bin b1.bin b2.bin b3.bin b4.bin b5.bin b6.bin > dos250ba.dat
	dd conv=notrunc if=dos250ba.dat of=doshead.bin bs=1 count=255
	dd conv=notrunc if=doshead.bin of=dos250ba.dat bs=1 count=255 seek=16k
	dd conv=notrunc if=doshead.bin of=dos250ba.dat bs=1 count=255 seek=32k
	dd conv=notrunc if=doshead.bin of=dos250ba.dat bs=1 count=255 seek=64k
	dd conv=notrunc if=doshead.bin of=dos250ba.dat bs=1 count=255 seek=96k
	dd conv=notrunc if=fdisk.dat of=dos250ba.dat bs=1 count=16000 seek=82176
	dd conv=notrunc if=fdisk2.dat of=dos250ba.dat bs=1 count=8000 seek=98560
	dd conv=notrunc if=doshead.bin of=dos250ba.dat bs=1 count=255 seek=80k
	dd conv=notrunc if=b4rd.bin of=dos250ba.dat bs=1 count=15 seek=65664

# --------------------------------------------------------------------------------------
# DRIVER: sunrise

$(BLDDIR)sunrise.hex: sunrise.rel
	@cd $(BLDDIR)
	l80.sh sunrise.hex /P:4100,SUNRISE,SUNRISE/N/X/Y/E

$(BLDDIR)sunrise.bin: sunrise.hex
	@cd $(BLDDIR)
	rm -f sunrise.bin
	hex2bin -s 4000 sunrise.hex

$(BLDDIR)srchgbnk.hex: srchgbnk.rel
	@cd $(BLDDIR)
	l80.sh srchgbnk.hex /P:7fd0,SRCHGBNK,SRCHGBNK/N/X/Y/E

$(BLDDIR)srchgbnk.bin: srchgbnk.hex
	@cd $(BLDDIR)
	rm -f srchgbnk.bin
	hex2bin -s 7FD0 srchgbnk.hex

$(BLDDIR)nextor-$(VERSION).sunriseide.rom: dos250ba.dat sunrise.bin srchgbnk.bin mknexrom
	@cd $(BLDDIR)
	mknexrom dos250ba.dat nextor-$(VERSION).sunriseide.rom -d:sunrise.bin -m:srchgbnk.bin
	cp -u nextor-$(VERSION).sunriseide.rom ../

## Build the sunrise rom image
sunrise: $(BLDDIR)nextor-$(VERSION).sunriseide.rom
	@

# --------------------------------------------------------------------------------------
# DRIVER: rc2014 using ASCII16 Banking


export BANK_SWITCH_CODE_ADDR := 32720 # 7FD0h

rc2014dr.rel: rc2014dr.mac cfdrv.mac embinc.mac
rcembdrv.rel: rcembdrv.mac embinc.mac

$(BLDDIR)rc2014dr.hex: rc2014dr.rel
	@cd $(BLDDIR)
	l80.sh rc2014dr.hex /P:4100,RC2014DR,RC2014DR/N/X/Y/E
	cleancpmfile.sh rc2014dr.sym
	cat rc2014dr.sym
	DRVEND=$$(getsymb.sh rc2014dr.sym DRVEND)
	if (($${DRVEND} > $${BANK_SWITCH_CODE_ADDR})); then
		printf "\e[31mDriver code overflow - driver bank has exceeded 16k\r\n\e[0m"
		exit 1
	fi

$(BLDDIR)rcembdrv.hex $(BLDDIR)rcembdrv.sym: rcembdrv.rel
	@cd $(BLDDIR)
	l80.sh rcembdrv.hex /P:4100,RCEMBDRV,RCEMBDRV/N/X/Y/E
	cleancpmfile.sh rcembdrv.sym
	SECEND=$$(getsymb.sh rcembdrv.sym SECEND)
	if (($${SECEND} > $${BANK_SWITCH_CODE_ADDR})); then
		printf "\e[31mDriver code overflow - driver bank has exceeded 16k\r\n\e[0m"
		exit 1
	fi

$(BLDDIR)rc2014dr.bin: rc2014dr.hex
	@cd $(BLDDIR)
	rm -f rc2014dr.bin
	hex2bin -s 4000 rc2014dr.hex
	filesize=$$(stat -c%s "rc2014dr.bin")
	if ((filesize > 16484 )); then
		echo -e "\r\nError: rc2014dr exceeded size of 16k"
		exit 1
	fi

$(BLDDIR)rcembdrv.bin: rcembdrv.hex
	@cd $(BLDDIR)
	rm -f rcembdrv.bin
	hex2bin -s 4000 rcembdrv.hex
	filesize=$$(stat -c%s "rcembdrv.bin")
	if ((filesize > 16484 )); then
		echo -e "\r\nError: rcembdrv exceeded size of 16k"
		exit 1
	fi

.PRECIOUS: %.hex

$(BLDDIR)rc2014-driver-with-sectors.bin: $(BLDDIR)rc2014dr.bin $(BLDDIR)rcembdrv.bin fdd.dsk
	@cd $(BLDDIR)
	SECSTRT=$$(getsymb.sh rcembdrv.sym SECSTR)
	DATSIZ=$$(getsymb.sh rcembdrv.sym DATSIZ)
	dd if=/dev/zero of=rc2014-driver-with-sectors.bin bs=16k count=20 seek=0
	dd conv=notrunc if=rc2014dr.bin of=rc2014-driver-with-sectors.bin bs=8k count=1 seek=0
	BNK_START_ADDR=$$((SECSTRT-16384))
	for i in {1..19}
	do
		BNK_ADDR=$$(($$BNK_START_ADDR + (16384*($$i))))
		SKIP=$$(($$DATSIZ*($$i-1)))
		dd conv=notrunc if=rcembdrv.bin of=rc2014-driver-with-sectors.bin bs=8k count=1 seek=$$((2*$$i))
		dd conv=notrunc if=fdd.dsk of=rc2014-driver-with-sectors.bin bs=1 count=$${DATSIZ} seek=$$BNK_ADDR skip=$$SKIP
	done

$(BLDDIR)ymchgbnk.hex: ymchgbnk.rel
	@cd $(BLDDIR)
	l80.sh ymchgbnk.hex /P:7fd0,YMCHGBNK,YMCHGBNK/N/X/Y/E

$(BLDDIR)ymchgbnk.bin: ymchgbnk.hex
	@cd $(BLDDIR)
	rm -f ymchgbnk.bin
	hex2bin -s 7FD0 ymchgbnk.hex

$(BLDDIR)nextor-$(VERSION).rc2014.rom: dos250ba.dat rc2014-driver-with-sectors.bin ymchgbnk.bin mknexrom
	@cd $(BLDDIR)
	mknexrom dos250ba.dat nextor-$(VERSION).rc2014.rom -d:rc2014-driver-with-sectors.bin -m:ymchgbnk.bin
	cp -u nextor-$(VERSION).rc2014.rom ../


# --------------------------------------------------------------------------------------
# FLOPPY DISK IMAGE FOR RC2014 DRIVER

EXTRAS = $(wildcard ../extras/*)
$(BLDDIR)fdd.dsk: nextor.sys command2.com fixdisk.com chkdsk.com $(EXTRAS) $(TOOLS_LIST) rcembdrv.sym
	@cd $(BLDDIR)
	DATSIZ=$$(getsymb.sh rcembdrv.sym DATSIZ)
	sudo umount -df /media/fdddsk > /dev/null 2>&1 || true
	rm -f fdd.dsk
	dd if=/dev/zero of=fdd.dsk bs=$$(($$DATSIZ*19)) count=1
	mkfs.vfat -F 12 -f 1 fdd.dsk
	sudo mkdir -p /media/fdddsk
	sudo mount -t vfat fdd.dsk /media/fdddsk
	sudo cp -v --preserve=timestamps *.com /media/fdddsk
	sudo cp -v --preserve=timestamps nextor.sys /media/fdddsk
	sudo cp -v --preserve=timestamps ../../extras/* /media/fdddsk
	sudo umount -df /media/fdddsk
	cp -u fdd.dsk ../

## Build a FAT12 floppy disk image containing nextor.sys, command2.com
fdddsk: $(BLDDIR)fdd.dsk

## Build the rc2014 rom image (ROM DISK)
rc2014: $(BLDDIR)nextor-$(VERSION).rc2014.rom
	@

# --------------------------------------------------------------------------------------
# mknexrom

$(BLDDIR)../../linuxtools/mknexrom: ../../wintools/mknexrom.c
	@cd $(BLDDIR)
	gcc ../../wintools/mknexrom.c -o ../../linuxtools/mknexrom

# ## build the mknexrom utility
mknexrom: $(BLDDIR)../../linuxtools/mknexrom
	@
