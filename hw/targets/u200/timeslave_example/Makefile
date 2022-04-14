DESIGN := ubts1a

include ../../common/vivado/common.mk

SYSDEF := vivado/$(DESIGN)/$(DESIGN).runs/impl_1/fpgaTop.sysdef

APP := eyescan
TEMPLATE_APP := empty_application

sw/hw_platform/fpgaTop.bit sw/hw_platform/fpgaTop.mmi sw/$(APP)/Makefile: $(SYSDEF)
	rm -rf sw/$(APP) sw/hw_platform
	cd sw && hsi -mode batch -source ../tcl/gen_app.tcl -tclargs $(DESIGN) $(APP)
	mv sw/$(APP)/$(TEMPLATE_APP)_bsp sw/$(APP)/bsp
	sed -i s/$(TEMPLATE_APP)_bsp/bsp/ sw/$(APP)/Makefile
	sed -i s/executable.elf/$(APP).elf/ sw/$(APP)/Makefile
	rm -f sw/$(APP)/*.c sw/$(APP)/README.txt
ifeq (${OS},Windows_NT)
	cp -a $(wildcard sw/src/$(APP)/*.[ch]) sw/$(APP)
else
	cd sw/$(APP) && ln -s -t . ../src/$(APP)/*.[ch]
endif

.PHONY: ELF
ELF: sw/$(APP)/Makefile
ifeq (${OS},Windows_NT)
	${MAKE} -C sw/$(APP) SHELL=CMD
else
	${MAKE} -C sw/$(APP)
endif

sw/hw_platform/fpgaTop_download.bit: sw/hw_platform/fpgaTop.bit sw/hw_platform/fpgaTop.mmi sw/$(APP)/$(APP).elf
	updatemem -meminfo sw/hw_platform/fpgaTop.mmi \
	    -data sw/$(APP)/$(APP).elf \
	    -bit  sw/hw_platform/fpgaTop.bit \
	    -proc arkafx1_0/eyescan_wrapper_0/eyescan_i/mb_ps/microblaze_1 \
	    -out  sw/hw_platform/fpgaTop_download.bit \
	    -force

.PHONY: $(APP)
$(APP): ELF sw/hw_platform/fpgaTop_download.bit
