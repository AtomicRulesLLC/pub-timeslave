SHELL=bash

DOBACKEND := false
ifeq (${DOBACKEND},true)
  TCLARGS := -tclargs doBackEnd
else
  TCLARGS :=
endif
# Run "make proj DOBACKEND=true MODE=batch" to compile w/o GUI.
MODE := gui
# Don't run Vivado in background if in batch mode, otherwise hard to kill process
ifeq (${MODE},gui)
  OPT_AMPERSAND := &
else
  OPT_AMPERSAND :=
endif

# Allow the data and commitsha to be overwritten from the caller.
COMMITSHA ?= $(shell git log -1 --pretty=%h 2> /dev/null)
DATE      ?= $(shell date +"%y%m%d_%H%M")

SCRIPTS_DIR := ../../common/scripts

default: usage
.PHONY: usage
usage:
	@printf "\n\
	Usage:\n\
	 proj                 removes current vivado directories and starts vivado\n\
	 DOBACKEND=true proj  removes current vivado directories and starts vivado synthesis\n\
	 DOBACKEND=true MODE=batch    proj  removes current vivado directories and starts vivado synthesis\n\
	 reopen		      reopens the last run -- keeping the current work\n\
	 init_fpga            loads bit stream into FPGA\n\
	 extract_bit          copy the bit file to the local dir\\n\
	 release_prep         copy the bit file and move the directory to /tmp\n"
	@if [[ -d ./ips ]] ; then printf "\
	 ip_gen:	      generate xci files for dependent IP\n\
	 ip_regen:	      generate xci files for dependent IP\n\
	" ; \
	fi
	@printf "\
	 \n\
	 sw_clean             cleans out software apps\n\
	 clean                cleans out vivado and software\n\
	 ip_prune	      interactively ask to clean ip directories\n\
	 realclean            interactively ask to clean all vivado directories\n\
	"


# We want to keep all the vivado runs so we create a directory with a data code and then
# create a link named 'vivado' to that directory
.PHONY: vivado
vivado:
	@rm -rf vivado
	mkdir -p vivado_$(DATE)
	ln  -s vivado_$(DATE) vivado

.PHONY: proj
proj: vivado
ifdef GEN_COMMIT_ID_VH
	@python $(SCRIPTS_DIR)/commit_id.py >| rtl/commit_id.vh
endif
	@cd vivado; vivado -mode $(MODE) -source ../tcl/create_$(DESIGN).tcl $(TCLARGS) $(OPT_AMPERSAND)

.PHONY: reopen
reopen:
	vivado -mode gui $(realpath vivado/$(DESIGN)/$(DESIGN).xpr) &

.PHONY: release_prep
release_prep:
	ln vivado/$(DESIGN)/$(DESIGN).runs/impl_1/fpgaTop_$(DESIGN).bit $(DESIGN)_fpgaTop.bit
	mv vivado/$(DESIGN) /tmp/$(DESIGN)_$(DATE)/


extract_bit:
	ln vivado/$(DESIGN)/$(DESIGN).runs/impl_1/fpgaTop_$(DESIGN).bit $(DESIGN)_$(DATE)_$(COMMITSHA).bit

design_name:
	@echo $(DESIGN)

###########
# Targets for building IP in sub directory
.PHONY: ip_gen
ip_gen: ips/ip_build_$(DESIGN).tcl
	cd ips && ./ip_build_$(DESIGN).tcl
# regenerate IP
.PHONY: ip_regen
ip_regen:
	cd ips && ./ip_build_$(DESIGN).tcl -overwrite 1

###########
# Cleaning
.PHONY: clean sw_clean realclean
sw_clean:
	rm -rf sw/hw_platform sw/$(APP) sw/hsi* sw/.Xil updatemem*

clean: sw_clean
	rm -rf vivado vivado.* .Xil ips/.Xil

realclean: clean prune ip_prune

prune:
	@printf "Select the number corresponding to file for removal\nSelect 0 to exit\n"
	@vx=`ls -d ips/vivado_ip_$(DESIGN) vivado_* *.bit` ; \
	select f in $$vx ; do \
	  if [[ -z $$f ]]; then \
	    break; \
         fi ; \
	    rm -rf $$f ;\
	done

ip_prune:
	@printf "Select the number corresponding to file for removal\nSelect 0 to exit\n"
	@vx=`ls -d ips/vivado_ip_$(DESIGN)/*` ; \
	select f in $$vx ; do \
	  if [[ -z $$f ]]; then \
	    break; \
         fi ; \
	    rm -rf $$f ;\
	done
