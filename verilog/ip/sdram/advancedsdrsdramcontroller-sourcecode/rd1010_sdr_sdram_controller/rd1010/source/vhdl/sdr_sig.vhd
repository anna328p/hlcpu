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
-- This is the signal module of the SDR SDRAM controller reference
-- design which generates all signals required to interface with the
-- SDR SDRAM.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :| Peter						 :| 10/18/09	:| Added Vhdl Support	
-- --------------------------------------------------------------------
LIBRARY ieee,STD,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--
use work.sdr_par.all;
--
ENTITY sdr_sig IS
   PORT (
      -----------------------------------------------------------------------
-- inputs
--

      sys_CLK                 : IN std_logic;
      sys_RESET               : IN std_logic;
      sys_A                   : IN std_logic_vector(RA_MSB DOWNTO CA_LSB);
      iState                  : IN std_logic_vector(3 DOWNTO 0);
      cState                  : IN std_logic_vector(3 DOWNTO 0);
      -----------------------------------------------------------------------
-- outputs
--

      sdr_CKE                 : OUT std_logic;
      sdr_CSn                 : OUT std_logic;
      sdr_RASn                : OUT std_logic;
      sdr_CASn                : OUT std_logic;
      sdr_WEn                 : OUT std_logic;
      sdr_BA                  : OUT std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
      sdr_A                   : OUT std_logic_vector(SDR_A_WIDTH - 1 DOWNTO 0));
END ENTITY sdr_sig;

ARCHITECTURE translated OF sdr_sig IS
attribute syn_keep : boolean;

   SIGNAL sdr_CKE_hdl            :  std_logic;
   SIGNAL sdr_CSn_hdl            :  std_logic;
   SIGNAL sdr_RASn_hdl           :  std_logic;
   SIGNAL sdr_CASn_hdl           :  std_logic;
   SIGNAL sdr_WEn_hdl            :  std_logic;
   SIGNAL sdr_BA_hdl             :  std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
   SIGNAL sdr_A_hdl              :  std_logic_vector(SDR_A_WIDTH - 1 DOWNTO 0);
attribute syn_keep of sdr_CSn_hdl : signal is true;
BEGIN
   sdr_CKE <= sdr_CKE_hdl;
   sdr_CSn <= sdr_CSn_hdl;
   sdr_RASn <= sdr_RASn_hdl;
   sdr_CASn <= sdr_CASn_hdl;
   sdr_WEn <= sdr_WEn_hdl;
   sdr_BA <= sdr_BA_hdl;
   sdr_A <= sdr_A_hdl;

   -----------------------------------------------------------------------
   -- SDR SDRAM Control Singals
   --

   PROCESS (sys_CLK, sys_RESET)
   BEGIN
      IF (sys_RESET = '1') THEN
         (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= INHIBIT AFTER tDLY;
         sdr_CKE_hdl <= '0' AFTER tDLY;
         sdr_BA_hdl <= (OTHERS => '1');
         sdr_A_hdl <= (OTHERS => '1');
      ELSIF (sys_CLK'EVENT AND sys_CLK = '1') THEN
         CASE iState IS
            WHEN ( i_tRP) |
                 ( i_tRFC1) |
                 ( i_tRFC2) |
                 ( i_tMRD) |
                 ( i_NOP) =>
                     (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= NOP AFTER tDLY;
                     sdr_CKE_hdl <= '1' AFTER tDLY;
                     sdr_BA_hdl <= (OTHERS => '1');
                     sdr_A_hdl <= (OTHERS => '1');
            WHEN i_PRE =>
                     (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= PRECHARGE AFTER tDLY;
                     sdr_CKE_hdl <= '1' AFTER tDLY;
                     sdr_BA_hdl <= (OTHERS => '1');
                     sdr_A_hdl <= (OTHERS => '1');
            WHEN (i_AR1) | (i_AR2) =>
                     (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= AUTO_REFRESH AFTER tDLY;
                     sdr_CKE_hdl <= '1' AFTER tDLY;
                     sdr_BA_hdl <= (OTHERS => '1');
                     sdr_A_hdl <= (OTHERS => '1');
            WHEN i_MRS =>
                     (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= LOAD_MODE_REGISTER AFTER tDLY;
                     sdr_CKE_hdl <= '1' AFTER tDLY;
                     sdr_BA_hdl <= (OTHERS => '0');
                     sdr_A_hdl <= "00" & MR_Write_Burst_Mode & MR_Operation_Mode & MR_CAS_Latency & MR_Burst_Type & MR_Burst_Length AFTER tDLY;
            WHEN i_ready =>
                     CASE cState IS
                        WHEN (c_idle) |
                             (c_tRCD) |
                             (c_tRFC) |
                             (c_cl) |
                             (c_rdata) |
                             (c_wdata) =>
                                 (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= NOP AFTER tDLY;
                                 sdr_CKE_hdl <= '1' AFTER tDLY;
                                 sdr_BA_hdl <= (OTHERS => '1');
                                 sdr_A_hdl <= (OTHERS => '1');
                        WHEN c_ACTIVE =>
                                 (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= ACTIVE1 AFTER tDLY;
                                 sdr_CKE_hdl <= '1' AFTER tDLY;
                                 sdr_BA_hdl <= sys_A(BA_MSB DOWNTO BA_LSB) AFTER tDLY;    -- bank
                                 sdr_A_hdl <= sys_A(RA_MSB DOWNTO RA_LSB) AFTER tDLY;    -- row
                        --column
                        --enable auto precharge

                        WHEN c_READA =>
                                 (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= READ AFTER tDLY;
                                 sdr_CKE_hdl <= '1' AFTER tDLY;
                                 sdr_BA_hdl <= sys_A(BA_MSB DOWNTO BA_LSB) AFTER tDLY;    -- bank
                                 --column
                                 --2 '0'(burst length 4)
                                 sdr_A_hdl <= sys_A(CA_MSB) & '1' & sys_A(CA_MSB - 1 downto CA_LSB) & "00" AFTER tDLY;
                        --column
                        --enable auto precharge

                        WHEN c_WRITEA =>
                                 (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= WRITE AFTER tDLY;
                                 sdr_CKE_hdl <= '1' AFTER tDLY;
                                 sdr_BA_hdl <= sys_A(BA_MSB DOWNTO BA_LSB) AFTER tDLY;    -- bank
                                 --column
                                 --2 '0'(burst length 4)
                                 sdr_A_hdl <= sys_A(CA_MSB) & '1' & sys_A(CA_MSB-1 downto CA_LSB)& "00";
                        WHEN c_AR =>
                                 (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= AUTO_REFRESH AFTER tDLY;
                                 sdr_CKE_hdl <= '1' AFTER tDLY;
                                 sdr_BA_hdl <= (OTHERS => '1');
                                 sdr_A_hdl <= (OTHERS => '1');
                        WHEN OTHERS  =>
                                 (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= NOP AFTER tDLY;
                                 sdr_CKE_hdl <= '1' AFTER tDLY;
                                 sdr_BA_hdl <= (OTHERS => '1');
                                 sdr_A_hdl <= (OTHERS => '1');

                     END CASE;
            WHEN OTHERS  =>
                     (sdr_CSn_hdl, sdr_RASn_hdl, sdr_CASn_hdl, sdr_WEn_hdl) <= NOP AFTER tDLY;
                     sdr_CKE_hdl <= '1' AFTER tDLY;
                     sdr_BA_hdl <= (OTHERS => '1');
                     sdr_A_hdl <= (OTHERS => '1');

         END CASE;
      END IF;
   END PROCESS;

END ARCHITECTURE translated;
