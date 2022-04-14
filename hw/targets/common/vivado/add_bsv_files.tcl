# To be sourced by Vivado create_*.tcl scripts.
# Adds BSV-generated files in lib/gen and BSV library file dependencies.

# NOTE: AR IPI cores already have subdependency on BSV libfiles.
# If the libfiles are added twice, will get Critical Warnings like
# [Synth 8-2490] overwriting previous definition of module FIFO.v
#
# Could change message severity:
# set_msg_config -id {Synth 8-2490} -new_severity {WARNING}
# or check that file of same name hasn't already been added,
# or check that BSV library isn't already included.
#
# Here we check that the BSV lib hasn't already been added via an IPI core.

if {[llength [get_files -quiet -filter {NAME =~ "*/ipshared/bluespec.com/*"}]] == 0} {
    # First get list of required library files
    array set REQUIRED_BSVFILES [list]
    foreach f [glob -nocomplain $projRoot/lib/gen/*_bsv_lib.use] {
        set fh [open $f "r"]
        set libfiles [split [string trim [read $fh]] "\n"]
        close $fh
        foreach g $libfiles {
            set REQUIRED_BSVFILES($g) true
        }
    }

    # Give preference to local copy of BSV lib files
    # (i.e in ../../../../cores/common/bsv vs. $env(BLUESPECDIR)/Verilog)
    # to get any enhancements; e.g. enhanced SizedFIFO.v.
    # Also give preference to files in bsv.generic over files in bsv.vivado
    # with same name. (e.g. bsv.vivado version of SizedFIFO.v forces RAMs to
    # be distributed with synthesis attribute.)
    # Original Vivado-specific files are from
    # [glob $env(BLUESPECDIR)/Verilog.Vivado/\[A-Z\]*.v]
    set src_libfiles [list]
    if {[info exists env(BLUESPECDIR)]} {
       set src_libfiles [concat ${src_libfiles} \
                                [glob $env(BLUESPECDIR)/Libraries/*.v]]
    }
    set src_libfiles [concat ${src_libfiles} \
        [glob -nocomplain ../../../../cores/common/bsv/\[A-Z\]*.v] \
        [glob -nocomplain ../../../../cores/common/bsv.vivado/\[A-Z\]*.v] \
        [glob -nocomplain ../../../../cores/common/bsv.generic/\[A-Z\]*.v] \
        ]

    foreach f ${src_libfiles} {
        set fbase [file tail $f]
        if {[info exists REQUIRED_BSVFILES($fbase)]} {
            set BSVFILES($fbase]) $f
        }
    }
    set bsvFilesList [list]
    foreach {k v} [array get BSVFILES] {
        lappend bsvFilesList $v
    }
    if {[llength $bsvFilesList] > 0} {
        add_files -norecurse $bsvFilesList
    }
}

# Now add files from lib/gen.
# Remove any files of same name already included by AR IPI cores.
# (Removing duplicate files is not necessary (and should not be done) in
# Vivado 2016.3 as each IPI BD is synthesized separately from the top-level,
# with its own set of files.)
set genFilesList [glob -nocomplain $projRoot/lib/gen/*.v]
set filteredList [list]
foreach f $genFilesList {
    set fbase [file tail $f]
    set match [get_files -quiet -filter "NAME =~ */$fbase"]
    if {([llength $match] > 0) && ([version -short] < "2016.3")} {
        puts "AR-NOTE: Skipping $f because file with same name already added from $match"
    } else {
        lappend filteredList $f
    }
}
if {[llength $filteredList] > 0} {
    add_files -norecurse $filteredList
}

###########################################################################
