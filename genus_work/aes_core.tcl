#set_attr max_print 1 CDFG2G/CDFG2G-503
#set_attr max_print 1 TIM/TIM-20
#set_attr max_print 1 GLO/GLO-12
#set_attr max_print 1 CDFG/CDFG-508
#set_attr max_print 1 VLOGPT/VLOGPT-35

set_attribute library ../../../LIB/Nangate_45_rechar_slow.lib
set inv_out INV_X2/ZN

source aes_core.load.tcl
elaborate aes_cipher_top

redirect /dev/null {
  set clock [define_clock -p 5000 -n clock [clock_ports]]
  external_delay -i 0 -c $clock /designs/*/ports_in/*
  external_delay -o 0 -c $clock /designs/*/ports_out/*
  if {[info exists std_load]} {
    set_attr external_wire_cap [expr 6 * $std_load] /des*/*/ports_out/*
  }

  set allins [find / -port ports_in/*]
  set clks [lsearch -glob $allins [clock_ports]]
  set noclksin [lreplace $allins $clks $clks]
  set_attr external_driver $inv_out $noclksin
}

set errorInfo ""

ungroup -flatten -all

synthesize -to_mapped -effort low
synthesize -incremental -effort high

report timing > ../rpt/timing.rpt
report gates > ../rpt/gates.rpt
report area > ../rpt/area.rpt

write -mapped > ../aes_core_final.v

#quit
