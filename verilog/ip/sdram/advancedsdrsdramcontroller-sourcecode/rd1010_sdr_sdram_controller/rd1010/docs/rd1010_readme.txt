            SDRAM CONTROLLER Reference Design
=====================================================================================================================================================

1. /RD1010/Docs/rd1010.pdf                                  						 --> Design document
   /RD1010/Docs/rd1010_readme.txt                            						 --> This document
   /RD1010/Docs/revision_history.txt                            					 --> Revision History

2. /RD1010/Project/<Device_name>/<language>/*.ldf           						 --> Lattice Diamond Design files to open diamond project
   /RD1010/Project/<Device_name>/<language>/*.lpf             						 --> Preference constraint file for Diamond or ispLEVER 8.1 SP01 
   /RD1010/Project/<Device_name>/<language>1/*.sty             					     -->Lattice Diamond Startegy file	

3. /RD1010/Simulation/<Device_name>/<language>/rtl_<language>.do					 --> RTL simulation script file
   /RD1010/Simulation/<Device_name>/<language>/timing_<language>.do	                 --> Timing simulation script file 
   

4. /RD1010/Source/Verilog/sdr_top.v                         	 					 --> Top file(verilog)
   /RD1010/Source/Verilog/sdr_ctrl.v                         						 --> Source file(verilog)
   /RD1010/Source/Verilog/sdr_data.v                        						 --> Source file(verilog)   
   /RD1010/Source/Verilog/sdr_sig.v                          						 --> Source file(verilog)
   /RD1010/Source/Verilog/sdr_par.v
   
   /RD1010/Source/Vhdl/sdr_top.vhd                         	  						 --> Top file(vhdl)
   /RD1010/Source/Vhdl/sdr_ctrl.vhd                          						 --> Source file(vhdl)
   /RD1010/Source/Vhdl/sdr_data.vhd                         						 --> Source file(vhdl)
   /RD1010/Source/Vhdl/sdr_par.vhd                           					     --> Source package file(vhdl)
   /RD1010/Source/Vhdl/sdr_sig.vhd                           						 --> Source file(vhdl)

5. /RD1010/Testbench/Verilog/sdr_tb.v                       						 --> Testbench (verilog top file)
    /RD1010/Testbench/Verilog/sdr_par.v                       						 --> Parameter file(verilog) 	
   /RD1010/Testbench/Vhdl/sdr_tb.vhd                        					     --> Testbench (vhdl top file)
   /RD1010/Testbench/Vhdl/sdr_par.vhd                          						 --> Parameter file(vhdl)

===================================================================================================  
!!IMPORTANT NOTES:!!
1. Unzip the RD1010_sdr_sdram_controller.zip file using the existing folder names.
2. Must copy the file, sdr_par.v, to the local directories for successful simulation
3. If there is lpf file or lci file available for the reference design:
	3.1 copy the content of the provided lpf file to the <project_name>.lpf file under your ispLEVER project, 
	3.2 use Constraint Files >> Add >> Exiting File to import the lpf to Diamond project and set it to be active,
	3.3 copy the content of the provided lct file to the <project_name>.lct under your cpld project.  
4. If there is sty file (strategy file for Diamond) available for the design, go to File List tab on the left 
   side of the GUI. Right click on Strategies >> Add >> Existing File. Then right click on the imported file 
   name and select "Set as Active Strategy".
5. Run the project in Diamond and generate verilog/vhdl simulation files before running .do script for simulation
===================================================================================================  
Using ispLEVER or ispLEVER Classic software
---------------------------------------------------------------------------------------------------
HOW TO CREATE A ISPLEVER OR ISPLEVER CLASSIC PROJECT:
1. Bring up ISPLEVER OR ISPLEVER CLASSIC software, in the GUI, select File >> New Project
2. In the New Project popup, select the Project location, provide a Project name, select Design Entry Type 
   and click Next.
3. Use RD1010.pdf to see which device /speedgrade should be selected to achieve the desired timing result
4. Add the necessary source files from the RD1010\source directory, click Next
5. Click Finish. Now the project is successfully created. 
6. Make sure the provided lpf or lct is used in the current directory. 

---------------------------------------------------------------------------------------------------
HOW TO RUN SIMULATION FROM ISPLEVER OR ISPLEVER CLASSIC PROJECT:
0. Make sure the sdr_par.v is in the same directory as the project file (.syn)
1. Import the top-level testbench into the project as test fixture and associate with the device
	1.1 Import the rest as Testbench Dependency File by highligh and right click on the test bench file
2. In the Project Navigator, highlight the testbench file on the left-side panel, user will see 3 
   simulation options on the right panel.
3. For functional simulation, double click on Verilog (or VHDL) Functional Simulation with Aldec 
   Active-HDL. Aldec simulator will be brought up, click yes to overwrite the existing file. The 
   simulator will initialize and run for 1us.
4. Type "run -all" for vhdl or "run -all" for verilog in the Console panel. A script similar to this 
   will be in the Console panel:

# KERNEL:                 1110ns : Coming Out Of Reset
# KERNEL:               101170ns : Precharge Command
# KERNEL:               101190ns : Auto Refresh Command
# KERNEL:               101270ns : Auto Refresh Command
# KERNEL:               101350ns : Load Mode Register 0x032
# KERNEL:               101350ns : mode: CAS Latency=0x3, Burst Length=0x4
# KERNEL:               101950ns : Activate Command
# KERNEL:               101970ns : Write Command
# KERNEL:               101970ns :write: Bank=0x0, Row=0x000, Column=0x000, Data=0x4
# KERNEL:               101990ns :write: Bank=0x0, Row=0x000, Column=0x001, Data=0x3
# KERNEL:               102010ns :write: Bank=0x0, Row=0x000, Column=0x002, Data=0x2
# KERNEL:               102030ns :write: Bank=0x0, Row=0x000, Column=0x003, Data=0x1
# KERNEL:               102130ns : Activate Command
# KERNEL:               102150ns : Write Command
# KERNEL:               102150ns :write: Bank=0x1, Row=0x000, Column=0x000, Data=0x8
# KERNEL:               102170ns :write: Bank=0x1, Row=0x000, Column=0x001, Data=0x7
# KERNEL:               102190ns :write: Bank=0x1, Row=0x000, Column=0x002, Data=0x6
# KERNEL:               102210ns :write: Bank=0x1, Row=0x000, Column=0x003, Data=0x5
# KERNEL:               102310ns : Activate Command
# KERNEL:               102330ns : Write Command
# KERNEL:               102330ns :write: Bank=0x2, Row=0x000, Column=0x000, Data=0xc
# KERNEL:               102350ns :write: Bank=0x2, Row=0x000, Column=0x001, Data=0xb
# KERNEL:               102370ns :write: Bank=0x2, Row=0x000, Column=0x002, Data=0xa
# KERNEL:               102390ns :write: Bank=0x2, Row=0x000, Column=0x003, Data=0x9
# KERNEL:               102490ns : Activate Command
# KERNEL:               102510ns : Write Command
# KERNEL:               102510ns :write: Bank=0x3, Row=0x000, Column=0x000, Data=0x0
# KERNEL:               102530ns :write: Bank=0x3, Row=0x000, Column=0x001, Data=0xf
# KERNEL:               102550ns :write: Bank=0x3, Row=0x000, Column=0x002, Data=0xe
# KERNEL:               102570ns :write: Bank=0x3, Row=0x000, Column=0x003, Data=0xd
# KERNEL:               102670ns : Activate Command
# KERNEL:               102690ns : Read Command
# KERNEL:               102735ns : read: Bank=0x0, Row=0x000, Column=0x000, Data=0x4
# KERNEL:               102755ns : read: Bank=0x0, Row=0x000, Column=0x001, Data=0x3
# KERNEL:               102775ns : read: Bank=0x0, Row=0x000, Column=0x002, Data=0x2
# KERNEL:               102795ns : read: Bank=0x0, Row=0x000, Column=0x003, Data=0x1
# KERNEL:               102890ns : Activate Command
# KERNEL:               102910ns : Read Command
# KERNEL:               102955ns : read: Bank=0x1, Row=0x000, Column=0x000, Data=0x8
# KERNEL:               102975ns : read: Bank=0x1, Row=0x000, Column=0x001, Data=0x7
# KERNEL:               102995ns : read: Bank=0x1, Row=0x000, Column=0x002, Data=0x6
# KERNEL:               103015ns : read: Bank=0x1, Row=0x000, Column=0x003, Data=0x5
# KERNEL:               103110ns : Activate Command
# KERNEL:               103130ns : Read Command
# KERNEL:               103175ns : read: Bank=0x2, Row=0x000, Column=0x000, Data=0xc
# KERNEL:               103195ns : read: Bank=0x2, Row=0x000, Column=0x001, Data=0xb
# KERNEL:               103215ns : read: Bank=0x2, Row=0x000, Column=0x002, Data=0xa
# KERNEL:               103235ns : read: Bank=0x2, Row=0x000, Column=0x003, Data=0x9
# KERNEL:               103330ns : Activate Command
# KERNEL:               103350ns : Read Command
# KERNEL:               103395ns : read: Bank=0x3, Row=0x000, Column=0x000, Data=0x0
# KERNEL:               103415ns : read: Bank=0x3, Row=0x000, Column=0x001, Data=0xf
# KERNEL:               103435ns : read: Bank=0x3, Row=0x000, Column=0x002, Data=0xe
# KERNEL:               103455ns : read: Bank=0x3, Row=0x000, Column=0x003, Data=0xd
# KERNEL: ------------------------------------------------------------
# KERNEL: ----------------------TEST PASS-----------------------------
# KERNEL: ------------------------------------------------------------
# RUNTIME: Info: RUNTIME_0070 sdr_tb.v (362): $stop called.
# KERNEL: Time: 103470 ns,  Iteration: 1,  Instance: /sdr_tb/SDR_SDRAM,  Process: @ALWAYS#336_3@.
# KERNEL: stopped at delta: 1 at time 103470 ns.

5. For timing simulation, double click on Verilog (or VHDL) Post-Route Timing Simulation with Aldec 
   Active-HDL. Similar message will be shown in the console panel of the Aldec Active-HDL simulator.
   5.1 Run -all to see the complete simulation
   5.1 In timing simulation you may see some warnings about narrow widths or vital glitches. These 
       warnings can be ignored. 
   5.2 Vital glitches can be removed by added a vsim command in the udo file. Use the udo.example 
       under the \project directory
   
===================================================================================================  
Using Diamond Software
---------------------------------------------------------------------------------------------------  
HOW TO CREATE A PROJECT IN DIAMOND:
1. Launch Diamond software, in the GUI, select File >> New Project, click Next
2. In the New Project popup, select the Project location and provide a Project name and implementation 
   name, click Next.
3. Add the necessary source files from the RD1010\source directory, click Next
4. Select the desired part and speedgrade. You may use RD1010.pdf to see which device and speedgrade 
   can be selected to achieve the published timing result 
5. Click Finish. Now the project is successfully created. 
6. MAKE SURE the provided lpf and/or sty files are used in the current directory. 
      
----------------------------------------------------------------------------------------------------      
HOW TO RUN SIMULATION UNDER DIAMOND:
1. Bring up the Simulation Wizard under the Tools menu 

2. Next provide a name for simulation project, and select RTL or post-route simulation
	2.1 For post-route simulation, must export verilog or vhdl simulation file after Place and Route
	
3. Next add the test bench files form the RD1010\TestBench directory & source files from RD1010\Source 
directory for Function Simation & exported post-route netlist file for Timing Simulation.
	3.1 For VHDL, make sure the top-level test bench is last to be added

4. Next click Finish, this will bring up the Aldec simulator automatically

5. In Aldec environment, you can manually activate the simulation or you can use a script
	5.1 Use the provided script in the RD1010\Simulation\<device> directory
		a. Click Tools > Execute Macro and select the xxx.do file to run the simulation
		b. This will run the simulation until finish
		
	5.2 Manually activate the simulation
		a. Click Simulation > Initialize Simulation
		b. Click File > New > Waveform, this will bring up the Waveform panel
		c. Click on the top-level testbench, drag all the signals into the Waveform panel
		d. At the Console panel, type "run -all" for VHDL simulation, or "run -all" for Verilog 
		   simulation
		e. For timing simulation, you must manually add 
		   -sdfmax UUT="../ecp5_verilog_lse_vo.sdf"
		   into the asim or vsim command. Use the command in timing_xxx.do as an example.

------------------------------------------------------------------------------------------------------------------
HOW TO RUN  SIMULATION IN STAND-ALONE MODE:

RTL SIMULATION 
1. In simulation directory open file RD1010/Simulation/<device>/<language>/rtl_<language>.do
2. In rtl_<language>.do set the path to your current simulation directory.
3. Open ALDEC Active HDL simulator in stand-alone mode and click on Tools-->Execute Macro.
4. Select RD1010/Simulation/<device>/<language>/rtl_<language>.do. The RTL simulation will commence, if not then recheck the simulation directory path in rtl_<language>.do file.

TIMING SIMULATION 
1. Before running timing simulation open the project in Diamond from project directory and generate vhdl/verilog simulation files .
2. In simulation directory open file RD1010/Simulation/<device>/<language>/timing_<language>_<synthesizer>.do
3. In timing_<language>.do set the path to your current simulation directory.
4. Open ALDEC Active HDL simulator in stand-alone mode and click on Tools-->Execute Macro.
5. Select RD1010/Simulation/<device>/<language>/timing_<language>.do. The timing simulation will commence, if not then recheck the simulation directory path in timing_<language>.do file.


