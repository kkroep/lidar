LinoSPAD starter pack
---------------------

The files in this archive will help to get you started with the LinoSPAD camera.

You will need:
 * A computer running a recent Linux distribution with:
   - GTK (for bootstrap software)
   - QT (for main GUI)
   - libusb-1.0 (for both)
 * All the additional hardware for the camera as listed in the documents in ./manual

Hardware setup (refer to the hardware manual for pin locations):
 * Place jumpers in the following locations:
   - J13.1-3 and J13.7-8 (FX3 boot configuration)
   - J9.1-2 (FPGA configuration flash)
   - J4.1-2 and J5.1-2 (3.3V FPGA I/O for daughterboard)
   - J22.1-2 (3.3V supply for daughterboard)
   - J3.3-4 (2.5V FPGA Bank0 voltage, oscillator works from 1.8V to 3.3V)
 * Connect 5V main logic power to J1.
 * The voltages given hereafter are safe start values and can be increased for better performance.
 * Connect external voltage supplies:
   - 1V quenching to J23.1 (GND J23.2)
     This is the gate voltage for the quenching transistor.
     A maximum voltage of 2V should be safe and 3.3V should not destroy the transistor. The SPAD
     lifetime will be reduced with higher voltages and consequently higher currents through the SPADs.
   - 20V main line SPAD bias to J23.3 (GND J23.4)
   - 20V aux SPAD bias to J23.5 (GND J23.6)
     SPAD bias can be connected together. Operation is possible up to 25V. The SPAD lifetime
     will be reduced with higher voltages and consequently higher currents through the SPADs.

The starter pack contains the following files:
 * Some documentation on the hardware and standard firmware for LinoSPAD in
   ./manual
 * Source and binary for the FX3 firmware typically loaded already in the flash.
   This is found in ./fx3_proj
 * The PC software is in ./pc_soft
   ./pc_soft/console contains a bootstrap software to read certain debug values
   and to initially load the FX3 firmware.
   ./pc_soft/QT/histplotter2 contains the main GUI to use LinoSPAD. Specific
   data output functions need to be added to this. Open histplotter2/src/LinoSPAD.pro
   in qtcreator to get started.
 * The sources and .bit-files for the reference firmware is in ./xil_ise
   ./xil_ise/refBootstrap contains a firmware to test transfer speeds and read
   some debug values.
   ./xil_ise/refMuxHists2 contains the reference firmware for LinoSPAD.
   The .bit files can be loaded in the FPGA or programmed in the flash through JTAG
   using Xilinx Impact.
   ./xil_ise/sim_refMuxHists2 contains VHDL testbenches for the main firmware modules.

Do not forget to enable USB hardware access. Adapt and copy 'cypress.rules' to '/etc/udev/rules.d/' to give
all users read/write access to Cypress (Vendor ID 0x04b4) hardware.

For the many remaining questions feel free to write to
  samuel.burri@epfl.ch

Samuel Burri, September 2015

Addendum:
 * A Windows version of the software is available in ./pc_soft/QT/histplotter2/LinoSPAD_Win32.exe
   For this version you need to install the WinUSB driver (a generic USB driver from Microsoft)
   for the LinoSPAD FX3. A tool to do this is available from http://zadig.akeo.ie/.
 * To build the Linux version in the ./pc_soft/QT/histplotter2/src/ directory run:
   - qmake LinoSPAD.pro
   - make
   - In Xubuntu 14.04.3 LTS you need 'qtcreator', 'libqt5svg5-dev' and 'libusb-1.0-0-dev';
     the executable is built in ./pc_soft/QT/histplotter2/LinoSPAD
 * To run the testbenches use GHDL 0.32rc1 (20141104) and GTKWave Analyzer v3.3.64.
   A trace from a toplevel simulation is in ./xil_ise/sim_refMuxHists2/toplevel_sim_wave.ghw.

