# xsdb Tcl script to download & run ELF on MicroBlaze
if {$argc < 1} {
    set appName app
} else {
    set appName [lindex $argv 0]
}
connect
target -filter {name =~ "MicroBlaze Debug Module*"} -set

jtagterminal
# set fp [open uart.log w]
# readjtaguart -start -handle $fp

target -filter {name =~ "MicroBlaze #0"} -set
catch {stop}
rst
dow sw/${appName}/${appName}.elf
con

