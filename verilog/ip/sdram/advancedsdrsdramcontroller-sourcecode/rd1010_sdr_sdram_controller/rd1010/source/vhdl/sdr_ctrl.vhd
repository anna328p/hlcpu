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
-- This is the main control module of the SDR SDRAM controller
-- reference design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :|Peter							 :| 10/17/09	:| Added Vhdl Supports
-- --------------------------------------------------------------------
library ieee,STD,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--
use work.sdr_par.all;
--
ENTITY sdr_ctrl IS
   PORT (
      -----------------------------------------------------------------------
-- inputs
--
      sys_CLK                 : IN std_logic;
      sys_RESET               : IN std_logic;
      sys_R_Wn                : IN std_logic;
      sys_ADSn                : IN std_logic;
      sys_DLY_100US           : IN std_logic;
      sys_REF_REQ             : IN std_logic;
      -----------------------------------------------------------------------
-- outputs
--

      sys_REF_ACK             : OUT std_logic;
      sys_CYC_END             : OUT std_logic;
      sys_INIT_DONE           : Buffer std_logic;
      iState                  : Buffer std_logic_vector(3 DOWNTO 0);
      cState                  : Buffer std_logic_vector(3 DOWNTO 0);
      clkCNT                  : Buffer std_logic_vector(3 DOWNTO 0));
END ENTITY sdr_ctrl;

ARCHITECTURE translated OF sdr_ctrl IS
   -----------------------------------------------------------------------
   -- registers
   --
   SIGNAL syncResetClkCNT          :  std_logic;   --  reset clkCNT to 0
   SIGNAL temp_hdl7               :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl8               :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl9               :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl10              :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl11              :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl12              :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl13              :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl14              :  std_logic;
   SIGNAL temp_hdl15              :  std_logic;
   SIGNAL temp_hdl16              :  std_logic;
   SIGNAL temp_hdl17              :  std_logic;
   SIGNAL temp_hdl18              :  std_logic;
   SIGNAL temp_hdl19              :  std_logic;
   SIGNAL temp_hdl20              :  std_logic;
   SIGNAL temp_hdl21              :  std_logic;
   SIGNAL temp_hdl22              :  std_logic;
--
   SIGNAL temp_hdl24              :  std_logic;
   SIGNAL temp_hdl25              :  std_logic;
   SIGNAL temp_hdl26              :  std_logic;
   --SIGNAL sys_REF_ACK        :  std_logic;
   --SIGNAL sys_CYC_END_hdl2        :  std_logic;
   --SIGNAL sys_INIT_DONE_hdl3      :  std_logic;
   --SIGNAL iState             :  std_logic_vector(3 DOWNTO 0);
   --SIGNAL cState             :  std_logic_vector(3 DOWNTO 0);
   --SIGNAL clkCNT             :  std_logic_vector(3 DOWNTO 0);

   --signal iState                  : std_logic_vector(3 DOWNTO 0);
   --signal cState_0                  : std_logic_vector(3 DOWNTO 0);


BEGIN
	 --iState <= iState;
	 --cState <= cState_0;
   --sys_REF_ACK 		<= sys_REF_ACK_hdl1;
   --sys_CYC_END 		<= sys_CYC_END_hdl2;
   --sys_INIT_DONE 	<= sys_INIT_DONE;
   --iState 				<= iState_hdl4;
   --cState 				<= cState;
  -- clkCNT 				<= clkCNT;
   temp_hdl7 		<= i_AR1 WHEN (NUM_CLK_tRP = 0) ELSE i_tRP;
   temp_hdl8 		<= i_AR2 WHEN (NUM_CLK_tRFC = 0) ELSE i_tRFC1;
   temp_hdl9 		<= i_MRS WHEN (NUM_CLK_tRFC = 0) ELSE i_tRFC2;
   temp_hdl10 		<= i_ready WHEN (NUM_CLK_tMRD = 0) ELSE i_tMRD;

   -----------------------------------------------------------------------
   -- local definitions
   --
   -----------------------------------------------------------------------
   -- INIT_FSM state machine
   --

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         iState <= i_NOP AFTER tDLY;
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         CASE iState IS
            WHEN (i_NOP) =>
                     -- wait for 100 us delay by checking sys_DLY_100US
                     IF (sys_DLY_100US = '1') THEN
                        iState <= i_PRE AFTER tDLY;
                     END IF;
            -- precharge all

            WHEN (i_PRE) =>
                     iState <= temp_hdl7 AFTER tDLY;
            WHEN (i_tRP) =>
                     -- wait until tRP satisfied

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_tRP,4)) THEN
                        iState <= i_AR1 AFTER tDLY;
                     END IF;
            -- auto referesh

            WHEN (i_AR1) =>
                     iState <= temp_hdl8 AFTER tDLY;
            WHEN (i_tRFC1) =>
                     -- wait until tRFC satisfied
                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_tRFC,4)) THEN
                        iState <= i_AR2 AFTER tDLY;
                     END IF;
            -- auto referesh

            WHEN (i_AR2) =>
                     iState <= temp_hdl9 AFTER tDLY;
            WHEN (i_tRFC2) =>
                     -- wait until tRFC satisfied

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_tRFC,4)) THEN
                        iState <= i_MRS AFTER tDLY;
                     END IF;
            -- load mode register

            WHEN (i_MRS) =>
                     iState <= temp_hdl10 AFTER tDLY;
            WHEN (i_tMRD) =>
                     -- wait until tMRD satisfied

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_tMRD,4)) THEN
                        iState <= i_ready AFTER tDLY;
                     END IF;
            WHEN (i_ready) =>
                     -- stay at this state for normal operation

                     iState <= i_ready AFTER tDLY;
            WHEN OTHERS  =>
                     iState <= i_NOP AFTER tDLY;

         END CASE;
      END IF;
   END PROCESS;

   --
   -- sys_INIT_DONE generation
   --

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         sys_INIT_DONE <= '0' AFTER tDLY;
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         CASE iState IS
            WHEN (i_ready) =>
                     sys_INIT_DONE <= '1' AFTER tDLY;
            WHEN OTHERS  =>
                     sys_INIT_DONE <= '0' AFTER tDLY;

         END CASE;
      END IF;
   END PROCESS;
   --
   temp_hdl11 <= c_READA WHEN (sys_R_Wn) = '1' ELSE c_WRITEA;
   temp_hdl12 <= c_READA WHEN (sys_R_Wn) = '1' ELSE c_WRITEA;
   temp_hdl13 <= c_idle WHEN (NUM_CLK_tRFC = 0) ELSE c_tRFC;

   -----------------------------------------------------------------------
   -- CMD_FSM state machine
   --

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         cState <= c_idle AFTER tDLY;
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         CASE cState IS
            WHEN (c_idle) =>
                     -- wait until refresh request or addr strobe asserted

                     IF ((sys_REF_REQ AND sys_INIT_DONE) = '1' ) THEN
                        cState <= c_AR AFTER tDLY;
                     ELSIF ((NOT sys_ADSn AND sys_INIT_DONE) = '1') THEN
                           cState <= c_ACTIVE AFTER tDLY;
                     END IF;
            WHEN (c_ACTIVE) =>
                     -- assert row/bank addr
                     IF (NUM_CLK_tRCD = 0) THEN
                        cState <= temp_hdl11 AFTER tDLY;
                     ELSE
                        cState <= c_tRCD AFTER tDLY;
                     END IF;
            WHEN (c_tRCD) =>
                     -- wait until tRCD satisfied
                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_tRCD,4)) THEN
                        cState <= temp_hdl12 AFTER tDLY;
                     END IF;
            WHEN (c_READA) =>
                     -- assert col/bank addr for read with auto-precharge

                     cState <= c_cl AFTER tDLY;
            WHEN (c_cl) =>
                     -- CASn latency

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_CL,4)) THEN
                        cState <= c_rdata AFTER tDLY;
                     END IF;
            WHEN (c_rdata) =>
                     -- read cycle data phase

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_READ - 1,4)) THEN
                        cState <= c_idle AFTER tDLY;
                     END IF;
            WHEN (c_WRITEA) =>
                     -- assert col/bank addr for write with auto-precharge

                     cState <= c_wdata AFTER tDLY;
            WHEN (c_wdata) =>
                     -- write cycle data phase

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_WRITE,4)) THEN
                        cState <= c_tDAL AFTER tDLY;
                     END IF;
            WHEN (c_tDAL) =>
                     -- wait until (tWR + tRP) satisfied before issuing next
                     -- SDRAM ACTIVE command

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_WAIT,4)) THEN
                        cState <= c_idle AFTER tDLY;
                     END IF;
            -- auto-refresh

            WHEN (c_AR) =>
                     cState <= temp_hdl13 AFTER tDLY;
            WHEN (c_tRFC) =>
                     -- wait until tRFC satisfied

                     IF (clkCNT = conv_std_logic_vector(NUM_CLK_tRFC,4)) THEN
                        cState <= c_idle AFTER tDLY;
                     END IF;
            WHEN OTHERS  =>
                     cState <= c_idle AFTER tDLY;

         END CASE;
      END IF;
   END PROCESS;

   --
   -- sys_REF_ACK generation
   --

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         sys_REF_ACK <= '0' AFTER tDLY;
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         CASE cState IS
            WHEN (c_idle) =>
                     IF ((sys_REF_REQ AND sys_INIT_DONE) ='1' ) THEN
                        sys_REF_ACK <= '1' AFTER tDLY;
                     ELSE
                        sys_REF_ACK <= '0' AFTER tDLY;
                     END IF;
            WHEN (c_AR) =>
                     IF (NUM_CLK_tRFC = 0) THEN
                        sys_REF_ACK <= '0' AFTER tDLY;
                     ELSE
                        sys_REF_ACK <= '1' AFTER tDLY;
                     END IF;
            WHEN OTHERS  =>
                     sys_REF_ACK <= '0' AFTER tDLY;

         END CASE;
      END IF;
   END PROCESS;
   --
   --
   temp_hdl14 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_READ,4) - "0001") ELSE '0';
   temp_hdl15 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_WAIT,4)) ELSE '0';

   --
   -- sys_CYC_END generation
   --

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         sys_CYC_END <= '1' AFTER tDLY;
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         CASE cState IS
            WHEN (c_idle) =>
                     IF ((sys_REF_REQ AND sys_INIT_DONE) = '1') THEN
                        sys_CYC_END <= '1' AFTER tDLY;
                     ELSIF ((NOT sys_ADSn AND sys_INIT_DONE)='1' ) THEN
                           sys_CYC_END <= '0' AFTER tDLY;
                     ELSE
                           sys_CYC_END <= '1' AFTER tDLY;
                     END IF;
            WHEN (c_ACTIVE) | (c_tRCD) | (c_READA) | (c_cl) | (c_WRITEA) | (c_wdata ) =>
                     sys_CYC_END <= '0' AFTER tDLY;
            WHEN (c_rdata) =>
                     sys_CYC_END <= temp_hdl14 AFTER tDLY;
            WHEN (c_tDAL) =>
                     sys_CYC_END <= temp_hdl15 AFTER tDLY;
            WHEN OTHERS  =>
                     sys_CYC_END <= '1' AFTER tDLY;
         END CASE;
      END IF;
   END PROCESS;

   -----------------------------------------------------------------------
   -- Clock Counter
   --
   PROCESS (sys_CLK)
   BEGIN
      IF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         IF (syncResetClkCNT = '1') THEN
            clkCNT <= "0000" AFTER tDLY;
         ELSE
            clkCNT <= clkCNT + "0001" AFTER tDLY;
         END IF;
      END IF;
   END PROCESS;
   --
   temp_hdl16 <= '1' WHEN (NUM_CLK_tRP = 0) ELSE '0';
   temp_hdl17 <= '1' WHEN (NUM_CLK_tRFC = 0) ELSE '0';
   temp_hdl18 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_tRP,4)) ELSE '0';
   temp_hdl19 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_tMRD,4)) ELSE '0';
   temp_hdl20 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_tRFC,4)) ELSE '0';
   temp_hdl21 <= '1' WHEN (NUM_CLK_tRCD = 0) ELSE '0';
   temp_hdl22 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_tRCD,4)) ELSE '0';

   temp_hdl24 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_CL,4)) ELSE '0';
   temp_hdl25 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_READ,4)) ELSE '0';
   temp_hdl26 <= '1' WHEN (clkCNT = conv_std_logic_vector(NUM_CLK_WRITE,4)) ELSE '0';

   --
   -- syncResetClkCNT generation
   --

   PROCESS (iState,cState,temp_hdl16,temp_hdl17,temp_hdl18,temp_hdl19,temp_hdl20,temp_hdl21,temp_hdl22,temp_hdl24,temp_hdl25,temp_hdl26)
   BEGIN
      CASE iState IS
         WHEN (i_PRE) =>
             syncResetClkCNT <= temp_hdl16 AFTER tDLY;
         WHEN (i_AR1) | (i_AR2) =>
                  syncResetClkCNT <= temp_hdl17 AFTER tDLY;
         WHEN (i_NOP) =>
                  syncResetClkCNT <= '1' AFTER tDLY;
         WHEN (i_tRP) =>
                  syncResetClkCNT <= temp_hdl18 AFTER tDLY;
         WHEN (i_tMRD) =>
                  syncResetClkCNT <= temp_hdl19 AFTER tDLY;
         WHEN (i_tRFC1) |(i_tRFC2) =>
                  syncResetClkCNT <= temp_hdl20 AFTER tDLY;
         WHEN (i_ready) =>
                  CASE cState IS
                     WHEN (c_ACTIVE) =>
                         syncResetClkCNT <= temp_hdl21 AFTER tDLY;
                     WHEN (c_idle) =>
                              syncResetClkCNT <= '1' AFTER tDLY;
                     WHEN (c_tRCD) =>
                              syncResetClkCNT <= temp_hdl22 AFTER tDLY;
                     WHEN (c_tRFC) =>
                              syncResetClkCNT <= temp_hdl20 AFTER tDLY;
                     WHEN (c_cl) =>
                              syncResetClkCNT <= temp_hdl24 AFTER tDLY;
                     WHEN (c_rdata) =>
                              syncResetClkCNT <= temp_hdl25 AFTER tDLY;
                     WHEN (c_wdata) =>
                              syncResetClkCNT <= temp_hdl26 AFTER tDLY;
                     WHEN OTHERS  =>
                              syncResetClkCNT <= '0' AFTER tDLY;

                  END CASE;
         WHEN OTHERS  =>
                  syncResetClkCNT <= '0' AFTER tDLY;

      END CASE;
   END PROCESS;

END ARCHITECTURE translated;
