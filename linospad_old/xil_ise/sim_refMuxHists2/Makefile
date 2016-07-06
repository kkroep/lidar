all:
	rm -rf libs/work
	mkdir -p libs/work
	ghdl -i --workdir=libs/work ../refMuxHists2/*.vhd
	ghdl -i --workdir=libs/work ../refMuxHists2/ipcore_dir/*.vhd
	ghdl -i --workdir=libs/work *.vhd
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work hist_tdc_tb
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work tdc_hist_module_tb
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work hist_equalizer_tb
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work tdc_array_tb
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work clock_control_tb
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work intensity_tb
	ghdl -m -Plibs/unisim -Plibs/XilinxCoreLib --workdir=libs/work --ieee=synopsys -fexplicit toplevel_tb
xillibs: $(XILINX)/vhdl/src/unisims/unisim_VCOMP.vhd $(XILINX)/vhdl/src/unisims/unisim_VPKG.vhd
	rm -rf libs/work
	mkdir -p libs/unisim
	mkdir -p libs/XilinxCoreLib
	ghdl -i --work=unisim --workdir=libs/unisim $(XILINX)/vhdl/src/unisims/*.vhd
	ghdl -i --work=unisim --workdir=libs/unisim $(XILINX)/vhdl/src/unisims/primitive/*.vhd
	ghdl -i --work=XilinxCoreLib --workdir=libs/XilinxCoreLib $(XILINX)/vhdl/src/XilinxCoreLib/fifo_generator_v9_3*.vhd
clean:
	rm -rf libs
	rm -rf *.o *.cf	
clean_binaries:
	rm -rf *tb

