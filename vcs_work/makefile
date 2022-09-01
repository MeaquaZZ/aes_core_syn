# f=gate_rtl.f
f=gate.f

all: clean compile simulate

compile:
	vcs \
 	-cm tgl \
	-full64 \
	-sverilog \
	-debug_all \
	+notimingcheck \
	+nospecify \
	+v2k \
	-l com.log \
	-f $(f)
	
simulate:
	./simv -l sim.log +notimingcheck +nospecify

clean:
	@rm -rf csrc DVEfiles simv simv.daidir ucli.key VCS*
	@rm -rf *.log *.vcd *.vpd *.ddc *.svf *.SDF *Synth *Netlist* work vsim* transcript

dve:
	dve&
