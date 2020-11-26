--   ==================================================================
--   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
--   ------------------------------------------------------------------
--   Copyright (c) 2013 by Lattice Semiconductor Corporation
--   ALL RIGHTS RESERVED 
--   ------------------------------------------------------------------
--
--   Permission:
--
--      Lattice SG Pte. Ltd. grants permission to use this code
--      pursuant to the terms of the Lattice Reference Design License Agreement. 
--
--
--   Disclaimer:
--
--      This VHDL or Verilog source code is intended as a design reference
--      which illustrates how these types of functions can be implemented.
--      It is the user's responsibility to verify their design for
--      consistency and functionality through the use of formal
--      verification methods.  Lattice provides no warranty
--      regarding the use or functionality of this code.
--
--   --------------------------------------------------------------------
--
--                  Lattice SG Pte. Ltd.
--                  101 Thomson Road, United Square #07-02 
--                  Singapore 307591
--
--
--                  TEL: 1-800-Lattice (USA and Canada)
--                       +65-6631-2000 (Singapore)
--                       +1-503-268-8001 (other locations)
--
--                  web: http:--www.latticesemi.com/
--                  email: techsupport@latticesemi.com
--
--   --------------------------------------------------------------------
--
-- This file contains the parameters used in the SDR SDRAM controller
-- reference design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
-- --------------------------------------------------------------------
library ieee;               
use ieee.std_logic_1164.all;
package sdr_par is
constant tDLY:time := 2 ns; -- 2ns delay for simulation purpose

-----------------------------------------------------------------------
-- SDRAM mode register definition
--

-- Write Burst Mode
constant Programmed_Length:std_logic := '0';
constant Single_Access    :std_logic := '1';

-- Operation Mode
--constant Standard :std_logic_vector(1 downto 0) := "00";

--CAS Latency
constant Latency_2:std_logic_vector(2 downto 0) := "010";
constant Latency_3:std_logic_vector(2 downto 0) := "011";

-- Burst Type
constant Sequential :std_logic:= '0';
constant Interleaved:std_logic:= '1';

-- Burst Length
constant Length_1:std_logic_vector(2 downto 0)	:= "000";
constant Length_2:std_logic_vector(2 downto 0)	:= "001";
constant Length_4:std_logic_vector(2 downto 0)	:= "010";
constant Length_8:std_logic_vector(2 downto 0)	:= "011";

-----------------------------------------------------------------------
-- User modifiable parameters
--

--/****************************
--* Mode register setting
--****************************/

constant MR_Write_Burst_Mode:std_logic := Programmed_Length;
--                                // Single_Access;

constant MR_Operation_Mode:std_logic_vector(1 downto 0) := "00";

constant MR_CAS_Latency : std_logic_vector(2 downto 0) := Latency_3;

constant MR_Burst_Type:std_logic :=    Sequential;
                                --// Interleaved;

constant MR_Burst_Length:std_logic_vector(2 downto 0) :=  Length_4;

--/****************************
--* Bus width setting
--****************************/

--
--           23 ......... 12     11 ....... 10      9 .........0
-- sys_A  : MSB <-------------------------------------------> LSB
--
-- Row    : RA_MSB <--> RA_LSB
-- Bank   :                    BA_MSB <--> BA_LSB
-- Column :                                       CA_MSB <--> CA_LSB
--

constant RA_MSB:integer := 22;
constant RA_LSB:integer := 11;

constant BA_MSB :integer := 10;
constant BA_LSB :integer :=  9;

constant CA_MSB :integer:=  8;
constant CA_LSB :integer:=  0;

constant SDR_BA_WIDTH :integer:=  2; -- BA0,BA1
constant SDR_A_WIDTH  :integer:= 12; -- A0-A11

--/****************************
--* SDRAM AC timing spec
--****************************/

--parameter tCK  = 12; //Comments by Zhipeng
constant tCK  :time:= 20 ns;
--constant t_TIME	:time := 7 ns;	
constant tMRD :time:= 2 * tCK;
constant tRP  :time:= 15 ns;
constant tRFC :time:= 66 ns;
constant tRCD :time:= 15 ns;
constant tWR  :time:= tCK + ( 7 ns);
constant tDAL :time:= tRP + tWR;

-----------------------------------------------------------------------
-- Clock count definition for meeting SDRAM AC timing spec
--

constant NUM_CLK_tMRD :integer:= tMRD/tCK;
constant NUM_CLK_tRP  :integer:= tRP/tCK;
constant NUM_CLK_tRFC :integer:= tRFC/tCK;
constant NUM_CLK_tRCD :integer:= tRCD/tCK;
constant NUM_CLK_tDAL :integer:= tDAL/tCK;

-- tDAL needs to be satisfied before the next sdram ACTIVE command can
-- be issued. State c_tDAL of CMD_FSM is created for this purpose.
-- However, states c_idle, c_ACTIVE and c_tRCD need to be taken into
-- account because ACTIVE command will not be issued until CMD_FSM
-- switch from c_ACTIVE to c_tRCD. NUM_CLK_WAIT is the version after
-- the adjustment.
--parameter NUM_CLK_WAIT = (NUM_CLK_tDAL < 3) ? 0 : NUM_CLK_tDAL - 3;
constant NUM_CLK_WAIT:integer:= 0 ;--when (NUM_CLK_tDAL < 3) else (NUM_CLK_tDAL - 3) ;
--parameter NUM_CLK_CL    = (MR_CAS_Latency == Latency_2) ? 2 :
--                          (MR_CAS_Latency == Latency_3) ? 3 :
--                          2;  // default
constant NUM_CLK_CL:integer:=3;
--parameter NUM_CLK_READ  = (MR_Burst_Length == Length_1) ? 1 :
--                          (MR_Burst_Length == Length_2) ? 2 :
--                          (MR_Burst_Length == Length_4) ? 4 :
--                          (MR_Burst_Length == Length_8) ? 8 :
--                          4; // default
constant NUM_CLK_READ:integer:=4;
--
--parameter NUM_CLK_WRITE = (MR_Burst_Length == Length_1) ? 1 :
--                          (MR_Burst_Length == Length_2) ? 2 :
--                          (MR_Burst_Length == Length_4) ? 4 :
--                          (MR_Burst_Length == Length_8) ? 8 :
--                          4; // default
constant NUM_CLK_WRITE:integer:=4;
--//---------------------------------------------------------------------
--// INIT_FSM state variable assignments (gray coded)
--//

constant i_NOP   :std_logic_vector(3 downto 0):= "0000";
constant i_PRE   :std_logic_vector(3 downto 0):= "0001";
constant i_tRP   :std_logic_vector(3 downto 0):= "0010";
constant i_AR1   :std_logic_vector(3 downto 0):= "0011";
constant i_tRFC1 :std_logic_vector(3 downto 0):= "0100";
constant i_AR2   :std_logic_vector(3 downto 0):= "0101";
constant i_tRFC2 :std_logic_vector(3 downto 0):= "0110";
constant i_MRS   :std_logic_vector(3 downto 0):= "0111";
constant i_tMRD  :std_logic_vector(3 downto 0):= "1000";
constant i_ready :std_logic_vector(3 downto 0):= "1001";

-----------------------------------------------------------------------
-- CMD_FSM state variable assignments (gray coded)
--

constant c_idle  :std_logic_vector(3 downto 0) := "0000";
constant c_tRCD  :std_logic_vector(3 downto 0) := "0001";
constant c_cl    :std_logic_vector(3 downto 0) := "0010";
constant c_rdata :std_logic_vector(3 downto 0) := "0011";
constant c_wdata :std_logic_vector(3 downto 0) := "0100";
constant c_tRFC  :std_logic_vector(3 downto 0) := "0101";
constant c_tDAL  :std_logic_vector(3 downto 0) := "0110";
constant c_ACTIVE:std_logic_vector(3 downto 0) := "1000";
constant c_READA :std_logic_vector(3 downto 0) := "1001";
constant c_WRITEA:std_logic_vector(3 downto 0) := "1010";
constant c_AR    :std_logic_vector(3 downto 0) := "1011";

-----------------------------------------------------------------------
-- SDRAM commands (sdr_CSn, sdr_RASn, sdr_CASn, sdr_WEn)
--

constant INHIBIT           :std_logic_vector(3 downto 0) := "1111";
constant NOP               :std_logic_vector(3 downto 0) := "0111";
constant ACTIVE1            :std_logic_vector(3 downto 0) := "0011";
constant READ              :std_logic_vector(3 downto 0) := "0101";
constant WRITE             :std_logic_vector(3 downto 0) := "0100";
constant BURST_TERMINATE   :std_logic_vector(3 downto 0) := "0110";
constant PRECHARGE         :std_logic_vector(3 downto 0) := "0010";
constant AUTO_REFRESH      :std_logic_vector(3 downto 0) := "0001";
constant LOAD_MODE_REGISTER:std_logic_vector(3 downto 0) := "0000";

end sdr_par;