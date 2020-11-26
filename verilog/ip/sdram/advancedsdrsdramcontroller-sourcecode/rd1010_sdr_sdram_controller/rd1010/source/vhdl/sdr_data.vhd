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
-- This is the data path module of the SDR SDRAM controller reference
-- design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :| Peter						 :| 10/18/09  :| Added VHDL Support
-- --------------------------------------------------------------------
--
-- This is the data module for a synchronous DRAM controller.
-- 
LIBRARY ieee,STD,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--
use work.sdr_par.all;
--
ENTITY sdr_data IS
   PORT (
      -----------------------------------------------------------------------
-- inputs
--
      sys_CLK                 : IN std_logic;   
      sys_RESET               : IN std_logic;   
      -----------------------------------------------------------------------
-- bidir
--
      sys_D                   : INOUT std_logic_vector(15 DOWNTO 0);   
      -----------------------------------------------------------------------
-- outputs
--
      sys_D_VALID             : OUT std_logic;   
      cState                  : IN std_logic_vector(3 DOWNTO 0);   
      clkCNT                  : IN std_logic_vector(3 DOWNTO 0);   
      sdr_DQ                  : INOUT std_logic_vector(3 DOWNTO 0));   
END ENTITY sdr_data;

ARCHITECTURE translated OF sdr_data IS

   SIGNAL regSdrDQ                 :  std_logic_vector(15 DOWNTO 0);   
   SIGNAL enableSysD               :  std_logic;   
   SIGNAL regSysD                  :  std_logic_vector(15 DOWNTO 0);   
   SIGNAL regSysDX                 :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL enableSdrDQ              :  std_logic;   
   SIGNAL stateWRITEA              :  std_logic;   
   -- synthesys syn_keep=1 
   SIGNAL cnt0_sdrdq               :  std_logic_vector(3 DOWNTO 0);   
   -- synthesys syn_keep=1 
   SIGNAL cnt1_sdrdq               :  std_logic_vector(3 DOWNTO 0);   
   -- synthesys syn_keep=1 
   SIGNAL cnt2_sdrdq               :  std_logic_vector(3 DOWNTO 0);   
   -- synthesys syn_keep=1 
   SIGNAL cnt3_sdrdq               :  std_logic_vector(3 DOWNTO 0);   
   -----------------------------------------------------------------------
   --  Read Cycle Data Path
   --
   SIGNAL temp_hdl2               :  std_logic_vector(15 DOWNTO 0);   
   SIGNAL temp_hdl3               :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_hdl4               :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_hdl5               :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_hdl6               :  std_logic_vector(3 DOWNTO 0);   
   -----------------------------------------------------------------------
   --  Write Cycle Data Path
   --
   SIGNAL temp_hdl7               :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL temp_hdl8               :  std_logic;   
   SIGNAL sys_D_VALID_hdl1        :  std_logic;   
   
BEGIN
   sys_D_VALID <= sys_D_VALID_hdl1;
   -----------------------------------------------------------------------
   -- sys_D_VALID Generation
   --
   sys_D_VALID_hdl1 <= enableSysD  AFTER tDLY;
   temp_hdl2 <= regSdrDQ WHEN (enableSysD) = '1' ELSE "ZZZZZZZZZZZZZZZZ";
   sys_D <= temp_hdl2  AFTER tDLY ;
   temp_hdl3 <= sdr_DQ WHEN ((cState = c_rdata) AND (clkCNT = "0000")) ELSE regSdrDQ(3 DOWNTO 0);
   cnt0_sdrdq <= temp_hdl3 ;
   temp_hdl4 <= sdr_DQ WHEN ((cState = c_rdata) AND (clkCNT = "0001")) ELSE regSdrDQ(7 DOWNTO 4);
   cnt1_sdrdq <= temp_hdl4 ;
   temp_hdl5 <= sdr_DQ WHEN ((cState = c_rdata) AND (clkCNT = "0010")) ELSE regSdrDQ(11 DOWNTO 8);
   cnt2_sdrdq <= temp_hdl5 ;
   temp_hdl6 <= sdr_DQ WHEN ((cState = c_rdata) AND (clkCNT = "0011")) ELSE regSdrDQ(15 DOWNTO 12);
   cnt3_sdrdq <= temp_hdl6 ;

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         regSdrDQ <= "0000000000000000" AFTER tDLY;    
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         regSdrDQ <= cnt3_sdrdq & cnt2_sdrdq & cnt1_sdrdq & cnt0_sdrdq AFTER tDLY;    
      END IF;
   END PROCESS;

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         enableSysD <= '0' AFTER tDLY;    
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         IF ((cState = c_rdata) AND (clkCNT = conv_std_logic_vector(NUM_CLK_READ,4) - "0001")) THEN
            enableSysD <= '1' AFTER tDLY;    
         ELSE
            enableSysD <= '0' AFTER tDLY;    
         END IF;
      END IF;
   END PROCESS;
   temp_hdl7 <= regSysDX WHEN (enableSdrDQ) = '1' ELSE "ZZZZ";
   sdr_DQ <= temp_hdl7  AFTER tDLY;

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         regSysDX <= "0000" AFTER tDLY;    
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         IF (cState = c_WRITEA) THEN
            regSysDX <= regSysD(3 DOWNTO 0) AFTER tDLY;    
         ELSIF ((cState = c_wdata) AND (clkCNT = "0001")) THEN
            regSysDX <= regSysD(7 DOWNTO 4) AFTER tDLY;    
         ELSIF ((cState = c_wdata) AND (clkCNT = "0010")) THEN
            regSysDX <= regSysD(11 DOWNTO 8) AFTER tDLY;    
         ELSE
            regSysDX <= regSysD(15 DOWNTO 12) AFTER tDLY;    
         END IF;
      END IF;
   END PROCESS;
   temp_hdl8 <= '1' WHEN (cState = c_WRITEA) ELSE '0';
   stateWRITEA <= temp_hdl8  AFTER tDLY;

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         enableSdrDQ <= '0' AFTER tDLY;    
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
          IF (cState = c_WRITEA) THEN
            enableSdrDQ <= '1' AFTER tDLY;
          ELSIF ((cState = c_wdata) AND (clkCNT = NUM_CLK_WRITE)) THEN
            enableSdrDQ <= '0' AFTER tDLY;    
         END IF;
      END IF;
   END PROCESS;

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         regSysD <= x"0000" AFTER tDLY;    
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         regSysD <= sys_D AFTER tDLY;    
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
