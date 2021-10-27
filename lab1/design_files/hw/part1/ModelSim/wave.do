onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label reset /testbench/reset
add wave -noupdate -label clock /testbench/clock
add wave -noupdate -label A -radix hex /testbench/A
add wave -noupdate -label D -radix unsigned /testbench/D
add wave -noupdate -label W /testbench/W
add wave -noupdate -divider LFSR
add wave -noupdate -label Ctrl -radix binary /testbench/U1/Ctrl
add wave -noupdate -label Poly -radix unsigned /testbench/U1/Poly
add wave -noupdate -label Next -radix unsigned /testbench/U1/Next
add wave -noupdate -label Q -radix unsigned /testbench/U1/Q
add wave -noupdate -label FSM /testbench/U1/y
add wave -noupdate -label z /testbench/U1/z
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
