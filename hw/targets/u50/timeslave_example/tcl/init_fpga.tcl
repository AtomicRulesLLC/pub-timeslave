# xsdb Tcl script to download & run ELF on MicroBlaze
if {$argc < 1} {
    set appName app
} else {
    set appName [lindex $argv 0]
}
connect
target -filter {name =~ "xcvu9p"} -set
fpga sw/hw_platform/fpgaTop_download.bit
# target -filter {name =~ "MicroBlaze Debug Module*"} -set
# jtagterminal
target -filter {name =~ "MicroBlaze #0"} -set
catch {stop}
rst
dow sw/${appName}/${appName}.elf
con
