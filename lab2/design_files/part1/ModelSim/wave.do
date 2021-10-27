onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label reset /testbench/reset
add wave -noupdate -label clock /testbench/clk
add wave -noupdate -label ctrl /testbench/ctrl

add wave -noupdate -label address   -radix unsigned /testbench/address
add wave -noupdate -label readdatavalid /testbench/readdatavalid
add wave -noupdate -label read       /testbench/read
add wave -noupdate -label waitrequest /testbench/waitrequest
add wave -noupdate -label write      /testbench/write
add wave -noupdate -label writedata  -radix hexadecimal /testbench/writedata

add wave -noupdate -label transform_done  /testbench/U1/transform_done
add wave -noupdate -label pixel_counter  -radix unsigned /testbench/U1/pixel_counter
add wave -noupdate -label transform_state  -radix unsigned /testbench/U1/transform_state

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 88
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {77500 ps}
