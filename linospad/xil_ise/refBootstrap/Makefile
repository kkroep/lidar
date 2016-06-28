TOP=toplevel.vhd
#TOP.xst and TOP.ut needed

SOURCES=ipcore_dir/dcfifo_256x36.vhd usbmux.vhd systemid.vhd reset_generator.vhd
SOURCES+=ipcore_dir/clk48to100.vhd fx3_interface.vhd datasinksource.vhd
SOURCES+=loopback.vhd simplespi.vhd module_clock_adapter.vhd fx3_stats.vhd

XSTCONSTRAINTS=timing.xcf
CONSTRAINTS=timing.ucf toplevel.ucf

PARTNAME=xc6slx150-fgg676-3

XSTFLAGS=
NGDFLAGS=-dd _ngo -sd ipcore_dir -nt timestamp
MAPFLAGS=-ol high -xe n
XTRAMAPFLAGS=-detail
MAPFLAGS+=$(XTRAMAPFLAGS)
PARFLAGS=-ol high -xe n
TIMFLAGS=-s 3 -e 10000 -fastpaths
BITFLAGS=

NUMCORES=8
MAXRUNS=100
RUNALL=
XPLFLAGS=-p $(PARTNAME) -sd ".;./ipcore_dir" -wd smartxplorer_results -host_list hostlistfile.txt
XPLFLAGS+=-max_time "12:00:00" -max_runs $(MAXRUNS) -best_n_runs 3 -b $(RUNALL)

BASE=$(basename $(TOP))

EMPTY=
SPACE=$(EMPTY) $(EMPTY)

ifneq (,$(wildcard xpartition.pxml))
PARTFILE=import/xpartition.pxml
endif

ifneq (,$(wildcard $(BASE)_guide.ncd))
SMGFLAGS=-smartguide $(BASE)_guide.ncd
endif

make_smart=$(if $(wildcard $(BASE).ncd),\
$(shell cp $(BASE).ncd $(BASE)_guide.ncd)\
,$(error Guide file not found.))

all: $(BASE).twr $(BASE).bit

smart: $(BASE)_guide.ncd
	@echo Will use guided map/par...
	$(MAKE) all
	rm $(BASE)_guide.ncd

$(BASE)_guide.ncd:
	$(make_smart)

import/xpartition.pxml: xpartition.pxml
	cp xpartition.pxml import/

# Create .prj
$(BASE).prj: Makefile
	rm -f $(BASE).prj
	for file in $(SOURCES) $(TOP); do echo vhdl work \"$$file\" >> $@; done

# XST
$(BASE).ngc: $(BASE).xst $(BASE).prj $(TOP) $(SOURCES) $(XSTCONSTRAINTS) $(PARTFILE)
	rm -f *.hdx
	rm -f *.ngc
	rm -f *.ngr
	mkdir -p xst/projnav.tmp
	xst $(XSTFLAGS) -ifn $(BASE).xst -ofn $(BASE).syr

# Ngdbuild
$(BASE).ngd: $(BASE).ngc $(CONSTRAINTS) $(PARTFILE)
	ngdbuild -p $(PARTNAME) $(NGDFLAGS) $(patsubst %,-uc %,$(CONSTRAINTS)) $(BASE).ngc $(BASE).ngd

# Map
$(BASE)_map.ncd: $(BASE).ngd $(PARTFILE)
	map -p $(PARTNAME) $(MAPFLAGS) $(SMGFLAGS) -w -o $(BASE)_map.ncd $(BASE).ngd

# PAR
$(BASE).ncd: $(BASE)_map.ncd $(PARTFILE)
	par $(PARFLAGS) $(SMGFLAGS) $(BASE)_map.ncd -w $(BASE).ncd

# Bitgen
$(BASE).bit: $(BASE).ncd $(BASE).ut
	bitgen -f $(BASE).ut $(BASE).ncd

# Timing Report
$(BASE).twr: $(BASE).ncd
	trce $(TIMFLAGS) -tsi $(BASE).tsi -o $(BASE).twr $(patsubst %,-ucf %,$(CONSTRAINTS)) $(BASE).ncd $(BASE)_map.pcf

# Delay file
$(BASE).dly: $(BASE).ncd
	reportgen -delay $(BASE).ncd

export:
	mkdir -p import
	mv *.hdx import/
	mv *.ngc import/
	mv $(BASE)_prev_built.ngd import/
	mv $(BASE)_map_prev_mapped.ngm import/
	mv $(BASE)_map_prev_mapped.ncd import/
	mv $(BASE)_prev_routed.ncd import/

clean:
	rm -f *~ sim_ghdl/*~ ipcore_dir/*~
	rm -rf xst
	rm -rf _ngo
	rm -rf xlnx_auto_0_xdb
	rm -rf _xmsgs
	rm -f *.xds smartxplorer.log $(BASE)_sx.log
	rm -f $(BASE).lso $(BASE).ngr $(BASE).ngc $(BASE).syr $(BASE)_xst.xrpt
	rm -f $(BASE).ngd $(BASE).bld $(BASE)_ngdbuild.xrpt
	rm -f $(BASE)_map.* $(BASE).pcf
	rm -f par_usage_statistics.html $(BASE).ptwx $(BASE).pad $(BASE).unroutes $(BASE)_pad.csv $(BASE)_pad.txt
	rm -f $(BASE).ncd $(BASE).xpi $(BASE)_par.xrpt $(BASE).par $(BASE)_guide.ncd $(BASE).grf
	rm -f $(BASE).twx $(BASE).twx.html $(BASE).tsi $(BASE).twr $(BASE).drc $(BASE).bgn $(BASE)_bitgen.xwbt
	rm -f $(BASE)_unplaced.*
	rm -f planAhead*
	rm -f $(BASE)_summary.xml $(BASE)_usage.xml usage_statistics_webtalk.html webtalk.log
	rm -f reportgen.log $(BASE)_reportgen.xrpt $(BASE).dly $(BASE).prj hostlistfile.txt
	rm -f _impact.cmd _impact.log impact.xsl xilinx_device_details.xml
	rm -f *.hdx
	rm -f *.ngc
	rm -f *.ngr
	rm -f $(BASE)_prev_built.ngd
	rm -f $(BASE)_map_prev_mapped.ngm
	rm -f $(BASE)_map_prev_mapped.ncd
	rm -f $(BASE)_prev_routed.ncd

hostlistfile.txt: .FORCE
	rm -f hostlistfile.txt
	for i in `seq 1 $(NUMCORES)`; do echo localhost >> $@; done

xplore_all: hostlistfile.txt $(BASE).xst $(BASE).prj $(TOP) $(SOURCES)
	smartxplorer $(BASE).xst -ucf "$(subst $(SPACE),;,$(CONSTRAINTS))" $(XPLFLAGS)
xplore_map: hostlistfile.txt $(BASE).ngd
	smartxplorer $(BASE).ngd $(XPLFLAGS)
xplore_tables: hostlistfile.txt $(BASE).ngd
	smartxplorer $(BASE).ngd $(XPLFLAGS) -mo "$(MAPFLAGS)" -po "$(PARFLAGS)"

sim: $(BASE).ncd
	netgen -sta -w -aka -ne -dir sim $(BASE).ncd

.FORCE:

