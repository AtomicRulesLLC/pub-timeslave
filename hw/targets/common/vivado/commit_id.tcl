# Return git ID as string of eight hex digits, with first 7 hex digits being
# abbreviated commit hash, and eighth set to 0xf if there are uncommited
# changes, or 0 otherwise.


proc get_commit_id {} {
    if {[catch {exec git rev-parse --show-toplevel} res]} {
        get_commit_id_version
    } else {
        get_commit_id_git
    }

}

proc get_commit_id_git {} {
    if {[catch {exec git log -1 --pretty=format:%h --abbrev=7} result]} {
        puts "$result"
        puts "AR-ERROR: unable to get commit ID."
        set hash [format "%07x" 0]
    } else {
        set hash $result
    }
    set uncommitted_changes [catch {exec git diff --quiet} results options]
    if {$uncommitted_changes} {
        puts "AR-WARNING: You have uncommitted changes."
        set last_nibble f
    } else {
        set last_nibble 0
    }
    return $hash${last_nibble}
}

proc get_commit_id_version {} {
    set fname "version.txt"
    set dir   [file normalize [pwd]]
    set vfile ""
    set volumes [file volumes]
    while { $dir != "/" } {
        if { [lsearch -exact $volumes $dir] != -1} {
            break
        }
        set absname [file join $dir $fname]
        if {[file exists $absname]} {
            set vfile $absname
            break
        }
        set dir [file normalize [file join $dir "../"]]
    }
    if { $vfile == "" } {
        return  [format "%07x" 0]
    }

    set cmd {exec grep SHAID $vfile}
    if {[catch $cmd res]} {
        puts "Error could not extract version from $vfile"
        return  [format "%07x" 0]
    } else {
        if {[regexp {SHAID: (........)} $res unused r2]} {
            return $r2
        }
    }
    return  [format "%07x" 0]
}

proc create_commit_xdc {projRoot} {
    # Store first 32b of git commit ID in AXSS register of configuration block.
    set commit_id [get_commit_id]
    puts "AR-NOTE: Commit ID ${commit_id} will be stored in AXSS register."
    # Have to write command to XDC because at this stage [current_design] doesn't exist.
    set xdc "$projRoot/constrs/commit_id.xdc"
    set f [open $xdc w]
    puts $f "set_property BITSTREAM.CONFIG.USR_ACCESS ${commit_id} \[current_design\]"
    close $f
    add_files -fileset constrs_1 -norecurse $xdc
}
