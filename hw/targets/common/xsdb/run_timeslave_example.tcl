

proc cmac_init {} {
    if { [cmac_status] == 0 } {
        return 0;
    }
    for {set i 0} {$i < 10} {incr i} {
        set stat [cmac_reset]
        if {$stat == 0} break
        after 1000
    }
    if {$stat != 0} {
        puts stderr "Could not reset cmac"
        return -1
    }
    cmac_start
    return 0
}

proc cmac_reset {} {
    # qep_cmac_reset_all

    ## gt_reset
    mwr 0x000 1
    after 10
    mwr 0x000 0
    after 10

    #    mwr 0x004 0xFFFFFFFF
    mwr 0x004 0xC0000000
    after 100
    mwr 0x004 0x0


    # Set RSFEC
    mwr 0x107C 0x3

    # Clear on read
    set txstat  [mrd -value 0x200]
    set blocklk [mrd -value 0x20C]
    after 10

    set txstat  [mrd -value 0x200]
    set blocklk [mrd -value 0x20C]
    #puts "TX Stat: $txstat  Block Lock $blocklk"
    cmac_status
}

proc cmac_status {} {
    #puts -nonewline "TX Status (expect 0)   \t[mrd 0x0200]"
    #puts -nonewline "RX Status (expect 3)   \t[mrd 0x0204]"
    #puts -nonewline "Stat Status (expect 0) \t[mrd 0x0208]"
    #puts -nonewline "Block Lock   FFFFFF    \t[mrd 0x020C]"
    set bl [mrd -value 0x020C]
    return [expr $bl != 0xFFFFF]
}

proc cmac_start {} {
    ## Set tx_enable
    mwr 0x000C 1
    ## Set rx_enable
    mwr 0x0014 1
}


proc get_reg32 { addr } {
    return [mrd -value $addr ]
}
proc get_reg64 { addr } {
    return [mrd -value -size d $addr]
}
namespace import ::tcl::mathfunc::*
proc monitor_time {SHMEM_BASE} {
    proc int2flt { val } {
        if { [ expr $val & 0x80000000 ] } {
            set val [expr $val | 0xFFFFFFFF00000000]
        }
        return [double [format "%d" $val]]
    }

    set last_seq_id -1
    #ptpOffsetCount += 1.0;
    #ptpOffsetAccumulator += (double)status.last_delta;
    #ptpOffsetMean = ptpOffsetAccumulator / ptpOffsetCount;
    #ptpOffsetStdDevAccumulator += pow(((double)status.last_delta - ptpOffsetMean),2.0);
    #ptpOffsetStdDev = pow(ptpOffsetStdDevAccumulator/ptpOffsetCount,0.5);

    set ptpOffsetCount 0.0;
    set ptpOffsetAccumulator 0.0
    set ptpOffsetStdDevAccumulator 0.0
    set ptpOffsetStdDev  0.0
    set start_time [clock seconds]
    set time_probably_set_by_grandmaster 0
    set timeservo_locked 0
    set log_fp [open "ar_ptp_monitor.log" w]
    while { 1 } {
        set seq_id [get_reg32 [expr $SHMEM_BASE +0x0400]]
        if { $last_seq_id != $seq_id } {
            puts ""
            set slot_id [expr $seq_id & 3 ]
            set slot_addr [expr $SHMEM_BASE + [lindex {0x408 0x4A8 0x548 0x5e8} $slot_id ]]


            set portState [expr ([get_reg32  [expr $slot_addr + 0x08]]>>16) & 0xFF  ]
            set meanPathDelay [get_reg64  [expr $slot_addr + 0x48]]
            set time_secs [get_reg32 [expr $slot_addr + 0x58]]
            set frac_secs [get_reg32 [expr $slot_addr + 0x5C]]
            set last_delta [int2flt [get_reg32 [expr $slot_addr + 0x60]]]
            set last_phase_inc [get_reg64 [expr $slot_addr + 0x64]]
            set seq_errors [get_reg32 [expr $slot_addr + 0x6c]]
            set pkt_drops [get_reg32 [expr $slot_addr + 0x70]]
            set t1_secs [get_reg32 [expr $slot_addr + 0x74]]
            set t1_nano [get_reg32 [expr $slot_addr + 0x78]]
            set t2_secs [get_reg32 [expr $slot_addr + 0x7c]]
            set t2_nano [get_reg32 [expr $slot_addr + 0x80]]
            set t3_secs [get_reg32 [expr $slot_addr + 0x84]]
            set t3_nano [get_reg32 [expr $slot_addr + 0x88]]
            set t4_secs [get_reg32 [expr $slot_addr + 0x8c]]
            set t4_nano [get_reg32 [expr $slot_addr + 0x90]]
            set ref_clks_per_pps [get_reg32 [expr $slot_addr + 0x94]]
            set last_pps_time  [get_reg32 [expr $slot_addr + 0x98]]
            set pps_count  [get_reg32 [expr $slot_addr + 0x9C]]

            #puts "abs [abs [expr [clock seconds] - $time_secs ] ]"
            if { [abs [expr [clock seconds] - $time_secs ] ] < 10000 } {
                #if the timeservo's clock is in the general vacinity of host clock,
                #assume it has been set by a grandmaster
                set time_probably_set_by_grandmaster 1
            }
            puts [format "Date: %s" [clock format $time_secs]]
            puts [format "Epoch Second : %d" $time_secs]
            puts [format "Fractional Seconds : %d" $frac_secs]
            puts [format "Last  PTP Offset  (ns) %.0f" $last_delta]
            if { $time_probably_set_by_grandmaster && [abs $last_delta] < 100.0 } {
                set timeservo_locked 1
                #only do this part if delta below .1us to avoid filling up accumulators
                set ptpOffsetAccumulator [expr $ptpOffsetAccumulator + $last_delta]
                set ptpOffsetCount [expr $ptpOffsetCount + 1.0]
                set ptpOffsetMean [expr $ptpOffsetAccumulator / $ptpOffsetCount ]
                set ptpOffsetStdDevAccumulator [expr $ptpOffsetStdDevAccumulator + [pow [expr $last_delta - $ptpOffsetMean] 2.0]]
                set ptpOffsetStdDev [pow [expr $ptpOffsetStdDevAccumulator / $ptpOffsetCount] 0.5]
                puts [format "Mean  PTP Offset  (ns) %.1f" $ptpOffsetMean]
                puts [format "Sigma PTP Offset  (ns) %.2f" $ptpOffsetStdDev]
            }
            #write relevant data to time.log
            set phaseIncTops [expr [pow 10. 12]/[pow 2. 72]]
            set fmt_str [concat "%10u %d %24s %8.6f %12d %16.3f %6d %6d" \
                         " %10d_%09d" " %10d_%09d" " %10d_%09d" " %10d_%09d" \
                         " %6ld %10d %11.6f %10d"]

            puts -nonewline $log_fp \
                [format "%10u %1x %24s %8.6f %12.0f %16.3f %6d %6d" \
                 $seq_id \
                 $portState \
                 [clock format $time_secs] \
                 [expr $frac_secs / [pow 2.0 32]] \
                 $last_delta \
                 [expr $phaseIncTops * $last_phase_inc] \
                 $seq_errors \
                 $pkt_drops]
            puts -nonewline $log_fp \
                [format " %10d_%09d %10d_%09d %10d_%09d %10d_%09d" \
                 $t1_secs $t1_nano \
                 $t2_secs $t2_nano \
                 $t3_secs $t3_nano \
                 $t4_secs $t4_nano]
            puts $log_fp \
                [format " %6ld %10d %11.6f %10d" \
                 $meanPathDelay \
                 $ref_clks_per_pps \
                 [expr [int2flt $last_pps_time ] / [pow 2. 24]] \
                 $pps_count]
            flush $log_fp
        }

        if { $time_probably_set_by_grandmaster == 0 && [expr [clock seconds] - $start_time] > 10 } {
            puts "WARNING: NO PTP TIME FROM GRANDMASTER SEEN AFTER 10 SECONDS"
        }
        if { $timeservo_locked == 0  && [expr [clock seconds] - $start_time] > 180 } {
            puts "WARNING: 3 MIN HAS PASSED AND TIMESERVO NOT CONVERGED TO < 100ns "
        }

        after 1000
        set last_seq_id $seq_id
    }
}

connect
targets -set -filter {name == "JTAG2AXI"}
cmac_init
monitor_time  0x20000
