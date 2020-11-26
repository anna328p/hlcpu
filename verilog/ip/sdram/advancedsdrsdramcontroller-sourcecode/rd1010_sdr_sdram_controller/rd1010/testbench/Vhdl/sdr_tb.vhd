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
-- This is the test bench module of the SDR SDRAM controller reference
-- design.  It is highly recommanded to download simulation modules
-- from the SDRAM venders when you are working on the modification of
-- the SDR SDRAM controller reference design.
--
-- --------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author            :| Mod. Date :| Changes Made:
--   V0.1 :|                   :| 06/29/09  :| Pre-Release
--	 V4.3 :| Peter						 :| 10/26/09	:| Added VHDL Support
--   V4.4 :| LaxmiV						 :| 02/28/11  :| Fix a bug on read cycle to 
--                                             update dataout value after tAC_DLY
-- --------------------------------------------------------------------
-- 
LIBRARY ieee,std,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use std.env.all;
--use work.sdr_par.all; 
  
ENTITY sdr IS 
   GENERIC (  
      -----------------------------------------------------------------------
      -- parameters of 8 Meg x 4 x 4 banks
      --
      Num_Meg                        :  integer := 8;    --   8 Mb
      Data_Width                     :  integer := 4;    --   4 bits
      Num_Bank                       :  integer := 4;    --   4 banks
      tAC                            :  real := 5.4;
      tOH                            :  real := 2.7;
      SDR_A_WIDTH                    :  integer := 12;    --  12 bits
      SDR_BA_WIDTH                   :  integer := 2;    --  2 bits (4 banks)
      MEG                            :  std_logic_vector(20 DOWNTO 0) := "000000001000000000000";
      --MEM_SIZE                       :  integer := to_integer(to_stdlogicvector(Num_Meg, 21) * MEG * to_stdlogicvector(Num_Bank, 21));
      ROW_WIDTH                      :  integer := 12
      --COL_WIDTH                      :  integer := 11 --WHEN (Data_Width = 4) ELSE 0  
      );
      																						 --
      																						 --10 WHEN (Data_Width = 8) ELSE
      																						 --9  WHEN (Data_Width = 16)ELSE 0
      																						 
      
      
   PORT (
      sdr_DQ                  : INOUT std_logic_vector(Data_Width - 1 DOWNTO 0);
      -----------------------------------------------------------------------
-- ports
--
      sdr_A                   : IN std_logic_vector(SDR_A_WIDTH - 1 DOWNTO 0);
      sdr_BA                  : IN std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
      sdr_CK                  : IN std_logic;
      sdr_CKE                 : IN std_logic;
      sdr_CSn                 : IN std_logic;
      sdr_RASn                : IN std_logic;
      sdr_CASn                : IN std_logic;
      sdr_WEn                 : IN std_logic;
      sdr_DQM                 : IN std_logic
      );

END ENTITY sdr;

ARCHITECTURE translated OF sdr IS
	 constant MEM_SIZE               :  integer := Num_Meg * conv_integer(MEG) * Num_Bank;
	 --constant MEM_SIZE               :  integer := 64;
   constant COL_WIDTH              :  integer := 11;-- WHEN (Data_Width = 4) ELSE 10;-- WHEN (Data_Width = 8) ELSE 9 WHEN (Data_Width = 16) ELSE 0;
	 constant tAC_DLY                :  time    := 1 ns * integer(tAC);
	 constant tOH_DLY                :  time    := 1 ns * integer(tOH);
	 constant sdr_A_width_4x         :  integer := (SDR_A_WIDTH + 3)/4*4;
	 constant bank_width_4x          :  integer := (SDR_BA_WIDTH + 3)/4*4;
	 constant row_width_4x           :  integer := (ROW_WIDTH + 3)/4*4;
	 constant column_width_4x        :  integer := (COL_WIDTH +3)/4*4;
	 constant data_width_4x          :  integer := (Data_Width + 3)/4*4;
   constant zero4                  :  std_logic_vector(3 downto 0) :="0000";
																								 	   
   TYPE hdl_1 IS ARRAY (0 TO MEM_SIZE - 1) OF std_logic_vector(Data_Width - 1 DOWNTO 0);

   -----------------------------------------------------------------------
   -- registers
   --
   SIGNAL Memory                   :  hdl_1;
   SIGNAL Memory_read              :  hdl_1;
   SIGNAL casLatency               :  std_logic_vector(2 DOWNTO 0);
   SIGNAL casLatency_0             :  std_logic_vector(2 DOWNTO 0);
   SIGNAL casLatency_1             :  std_logic_vector(2 DOWNTO 0);
   SIGNAL burstLength              :  std_logic_vector(2 DOWNTO 0);
   SIGNAL burstLength_0            :  std_logic_vector(2 DOWNTO 0);
   SIGNAL burstLength_1            :  std_logic_vector(2 DOWNTO 0);
   SIGNAL bank                     :  std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
   SIGNAL bank_0                   :  std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
   SIGNAL bank_1                   :  std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
   SIGNAL row                      :  std_logic_vector(ROW_WIDTH - 1 DOWNTO 0);
   SIGNAL row_0                    :  std_logic_vector(ROW_WIDTH - 1 DOWNTO 0);
   SIGNAL row_1                    :  std_logic_vector(ROW_WIDTH - 1 DOWNTO 0);
   SIGNAL column                   :  std_logic_vector(COL_WIDTH - 1 DOWNTO 0):="00000000000";
   SIGNAL column_0                 :  std_logic_vector(COL_WIDTH - 1 DOWNTO 0);
   SIGNAL column_1                 :  std_logic_vector(COL_WIDTH - 1 DOWNTO 0);
   SIGNAL counter                  :  std_logic_vector(3 DOWNTO 0);
   SIGNAL counter_0                :  std_logic_vector(3 DOWNTO 0);
   SIGNAL counter_1                :  std_logic_vector(3 DOWNTO 0);
   SIGNAL dataOut                  :  std_logic_vector(Data_Width - 1 DOWNTO 0);
   SIGNAL dataOut_0                :  std_logic_vector(Data_Width - 1 DOWNTO 0);
   SIGNAL dataOut_1                :  std_logic_vector(Data_Width - 1 DOWNTO 0);
   SIGNAL enableSdrDQ              :  std_logic;
   SIGNAL enableSdrDQ_0            :  std_logic;
   SIGNAL enableSdrDQ_1            :  std_logic;
   SIGNAL write_state              :  std_logic;
   SIGNAL write_0                  :  std_logic;
   SIGNAL write_1                  :  std_logic;
   SIGNAL latency                  :  std_logic:='0';
   SIGNAL latency_0                :  std_logic;
   SIGNAL latency_1                :  std_logic;
   SIGNAL read                     :  std_logic;
   SIGNAL read_0                   :  std_logic;
   SIGNAL read_1                   :  std_logic;
   SIGNAL	temp_hdl1							 :  std_logic_vector(16 - 1 DOWNTO 0);
   SIGNAL temp_hdl2               :  std_logic_vector(16 - 1 DOWNTO 0);
   SIGNAL temp_hdl3               :  std_logic_vector(16 - 1 DOWNTO Data_width);

   SIGNAL temp_hdl5               :  std_logic_vector(15 DOWNTO 0);
   SIGNAL temp_hdl6               :  std_logic_vector(15 DOWNTO 0);
   SIGNAL temp_hdl7               :  std_logic_vector(15 DOWNTO 0);
   SIGNAL temp_hdl8               :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl9               :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl10              :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl11              :  std_logic_vector(3 DOWNTO 0);
   SIGNAL temp_hdl12              :  std_logic_vector(8 DOWNTO 0);
   SIGNAL temp_hdl13              :  std_logic_vector(9 DOWNTO 0);
   SIGNAL temp_hdl14              :  std_logic_vector(10 DOWNTO 0);
   SIGNAL temp_hdl15              :  std_logic_vector(8 DOWNTO 0);
   SIGNAL temp_hdl16              :  std_logic_vector(9 DOWNTO 0);
   SIGNAL temp_hdl17              :  std_logic_vector(10 DOWNTO 0);
   SIGNAL sdr_A_4x                 :  std_logic_vector(sdr_A_width_4x - 1 DOWNTO 0);
   SIGNAL bank_4x                  :  std_logic_vector(bank_width_4x - 1 DOWNTO 0);
   SIGNAL row_4x                   :  std_logic_vector(row_width_4x - 1 DOWNTO 0);
   SIGNAL column_4x                :  std_logic_vector(column_width_4x - 1 DOWNTO 0);
   SIGNAL sdr_DQ_4x                :  std_logic_vector(data_width_4x - 1 DOWNTO 0);
   SIGNAL dataOUT_4x               :  std_logic_vector(data_width_4x - 1 DOWNTO 0);
   signal write_count			   :  integer:=0;
   signal read_count			   :  integer:=0;
BEGIN

   -----------------------------------------------------------------------
   -- code
   --hwrite need 4x bit width
gen_0:IF (sdr_A_width_4x = SDR_A_WIDTH ) GENERATE
      sdr_A_4x   <= sdr_A;
   END GENERATE;
gen_1:IF (sdr_A_width_4x /= SDR_A_WIDTH ) GENERATE
      sdr_A_4x   <= zero4((sdr_A_width_4x - SDR_A_WIDTH) downto 1) & sdr_A;
   END GENERATE;
--   sdr_A_4x   <= sdr_A   when (sdr_A_width_4x = SDR_A_WIDTH ) else zero4((sdr_A_width_4x - SDR_A_WIDTH) downto 1) & sdr_A; 
gen_2:IF (bank_width_4x = SDR_BA_WIDTH ) GENERATE
      bank_4x   <= bank;
   END GENERATE;
gen_3:IF (bank_width_4x /= SDR_BA_WIDTH ) GENERATE
      bank_4x   <=zero4((bank_width_4x - SDR_BA_WIDTH) downto 1) & bank;
   END GENERATE;
--   bank_4x    <= bank    when (bank_width_4x = SDR_BA_WIDTH ) else zero4((bank_width_4x - SDR_BA_WIDTH) downto 1) & bank; 
gen_4:IF (row_width_4x = ROW_WIDTH ) GENERATE
      row_4x   <= row;
   END GENERATE;
gen_5:IF (row_width_4x /= ROW_WIDTH ) GENERATE
      row_4x   <=zero4((row_width_4x - ROW_WIDTH) downto 1) & row;
   END GENERATE;
--   row_4x     <= row     when (row_width_4x = ROW_WIDTH )     else zero4((row_width_4x - ROW_WIDTH) downto 1) & row; 
gen_6:IF (column_width_4x = COL_WIDTH ) GENERATE
      column_4x   <= column;
   END GENERATE;
gen_7:IF (column_width_4x /= COL_WIDTH ) GENERATE
      column_4x   <=zero4((column_width_4x - COL_WIDTH) downto 1) & column;
   END GENERATE;
--   column_4x  <= column  when (column_width_4x = COL_WIDTH )  else zero4((column_width_4x - COL_WIDTH) downto 1) & column; 
--   column_4x  <= zero4((column_width_4x - COL_WIDTH) downto 1) & column; 
gen_8:IF (data_width_4x = Data_Width ) GENERATE
      sdr_DQ_4x   <= sdr_DQ;
   END GENERATE;
gen_9:IF (data_width_4x /= Data_Width ) GENERATE
      sdr_DQ_4x   <=zero4((data_width_4x - Data_Width) downto 1) & sdr_DQ;
   END GENERATE;
--   sdr_DQ_4x  <= sdr_DQ  when (data_width_4x = Data_Width )   else zero4((data_width_4x - Data_Width) downto 1) & sdr_DQ; 
gen_10:IF (data_width_4x = Data_Width ) GENERATE
      dataOUT_4x   <= dataOUT;
   END GENERATE;
gen_11:IF (data_width_4x /= Data_Width ) GENERATE
      dataOUT_4x   <=zero4((data_width_4x - Data_Width) downto 1) & dataOUT;
   END GENERATE;
  -- dataOUT_4x <= dataOUT when (data_width_4x = Data_Width )   else zero4((data_width_4x - Data_Width) downto 1) & dataOUT; 
   PROCESS
      VARIABLE hdl_initial : BOOLEAN := TRUE;
   BEGIN
      IF (hdl_initial) THEN
         casLatency_0 <= "000";
         WAIT FOR 0 ns;
         burstLength_0 <= "000";
         WAIT FOR 0 ns;
         bank_0 <= (OTHERS => '0');
         row_0 <= (OTHERS => '0');
         column_0 <= (OTHERS => '0');
         counter_0 <= "0000";
         WAIT FOR 0 ns;
         dataOut_0 <= (OTHERS => '0');
         enableSdrDQ_0 <= '0';
         WAIT FOR 0 ns;
         write_0 <= '0';
         WAIT FOR 0 ns;
         latency_0 <= '0';
         WAIT FOR 0 ns;
         read_0 <= '0';
         WAIT FOR 0 ns;
         hdl_initial := FALSE;
      ELSE
         WAIT;
      END IF;
   END PROCESS;
   --
   temp_hdl1	<= (OTHERS => 'Z');
   --
   temp_hdl3 <= (OTHERS => '0');
   temp_hdl2 <= (temp_hdl3 & dataOut) WHEN enableSdrDQ = '1' ELSE temp_hdl1;


   --
   temp_hdl5 <= temp_hdl2 WHEN (Data_Width = 16) ELSE "0000000000000000";
   temp_hdl6 <= temp_hdl2 WHEN (Data_Width = 8) ELSE temp_hdl5;
   temp_hdl7 <= temp_hdl2 WHEN (Data_Width = 4) ELSE temp_hdl6;
   sdr_DQ <= temp_hdl7(Data_width -1 DOWNTO 0) ;
   --
   --
   temp_hdl8 <= "1000" WHEN (sdr_A(2 DOWNTO 0) = "011") ELSE "0000";
   temp_hdl9 <= "0100" WHEN (sdr_A(2 DOWNTO 0) = "010") ELSE temp_hdl8;
   temp_hdl10 <= "0010" WHEN (sdr_A(2 DOWNTO 0) = "001") ELSE temp_hdl9;
   temp_hdl11 <= "0001" WHEN (sdr_A(2 DOWNTO 0) = "000") ELSE temp_hdl10;
   --
   temp_hdl12 <= sdr_A(8 DOWNTO 0) WHEN (Data_Width = 16) ELSE "000000000";
   temp_hdl13 <= sdr_A(9 DOWNTO 0) WHEN (Data_Width = 8) ELSE ("0" & temp_hdl12);
   temp_hdl14 <= sdr_A(11) & sdr_A(9 DOWNTO 0) WHEN (Data_Width = 4) ELSE ("0" & temp_hdl13);
   --
   temp_hdl15 <= sdr_A(8 DOWNTO 0) WHEN (Data_Width = 16) ELSE "000000000";
   temp_hdl16 <= sdr_A(9 DOWNTO 0) WHEN (Data_Width = 8) ELSE ("0" & temp_hdl15);
   temp_hdl17 <= sdr_A(11) & sdr_A(9 DOWNTO 0) WHEN (Data_Width = 4) ELSE ("0" & temp_hdl16);
	 --
   PROCESS
      VARIABLE temp_hdl18  : std_logic_vector(3 DOWNTO 0);
      VARIABLE lin          : LINE;
	  --variable Memory                   :  hdl_1;
   BEGIN
      WAIT UNTIL (sdr_CK'EVENT AND sdr_CK = '1');
      temp_hdl18 := sdr_CSn & sdr_RASn & sdr_CASn & sdr_WEn;
      CASE temp_hdl18 IS
         WHEN "0000" =>
--                  display(to_string(NOW) & "ns : Load Mode Register " & to_hexstring(sdr_A));
                   write(lin,NOW);
                  write(lin," : Load Mode Register 0x");
                  hwrite(lin,sdr_A_4x);
                  writeline(output,lin); 
                  casLatency_1 <= sdr_A(6 DOWNTO 4);
                  WAIT FOR 0 ns;
                  burstLength_1 <= temp_hdl11(2 DOWNTO 0);
                  WAIT FOR 0 ns;
--                  display(to_string(NOW) & "ns : mode: CAS Latency=" & to_decstring(casLatency,CALC_DECLEN(casLatency)) & ",Burst Length=" & to_decstring(burstLength_1,CALC_DECLEN(burstLength_1)));
                  write(lin,NOW);
                  write(lin," : mode : CAS Latency = 0x");
                  hwrite(lin,'0' & casLatency);
              --    write(lin,", Burst Length = 0x");
                  hwrite(lin,'0' & burstLength_1);
              --    writeline(output,lin);
         WHEN "0001" =>
--                  display(to_string(NOW) & "ns : Auto Refresh Command");
                --    write(lin,NOW);                    
					write(lin," : Auto Refresh Command");
                  writeline(output,lin); 
         WHEN "0010" =>
--                  display(to_string(NOW) & "ns : Precharge Command");
                  write(lin,NOW);
                  write(lin," : Precharge Command");
                  writeline(output,lin);
         WHEN "0011" =>
--                  display(to_string(NOW) & "ns : Activate Command");
                  write(lin,NOW);
                  write(lin," : Activate Command");
                  writeline(output,lin);
                  row_1 <= sdr_A;
                  --WAIT FOR 0 ns;
         WHEN "0100" =>
--                  display(to_string(NOW) & "ns : Write Command");
                  write(lin,NOW);
                  write(lin," : Write Command");
                  writeline(output,lin);
                  column <= temp_hdl14; --?
                  --WAIT FOR 0 ns;
                  bank <= sdr_BA;
                  --WAIT FOR 0 ns;
                  write_1 <= '1';
                  --WAIT FOR 0 ns;
                  counter <= "0" & burstLength;
                  WAIT FOR 0 ns;
                  Memory(conv_integer(row & column & bank)) <= sdr_DQ;
                  WAIT FOR 0 ns;
				   write_count <= write_count +1;
                  --column <= column + '1';
--                  display(to_string(NOW) & "ns :write: Bank=" & to_decstring(bank,CALC_DECLEN(bank))
--                  		& ",Row=" & to_decstring(row,CALC_DECLEN(row))
--                  		& ",Column=" & to_decstring(column,CALC_DECLEN(column))
--                  		--& ",Data=" & to_hexstring(sdr_DQ));
--                  		& ",Data=" & to_decstring(sdr_DQ,CALC_DECLEN(sdr_DQ))
--                  		);
                  write(lin,NOW);
                  write(lin," : write : Bank = 0x");
                  hwrite(lin,bank_4x);
                  write(lin,", Row = 0x");
                  hwrite(lin,row_4x);
                  write(lin,", Column = 0x");
                  hwrite(lin,column_4x);
                  write(lin,", Data = 0x");
                  hwrite(lin,sdr_DQ_4x);
                  writeline(output,lin);
         WHEN "0101" =>
--                  display(to_string(NOW) & "ns : Read Command");
                  write(lin,NOW);
                  write(lin," : Read Command");
                  writeline(output,lin);
                  column <= temp_hdl17;--?
                  WAIT FOR 0 ns;
                  bank <= sdr_BA;
                  WAIT FOR 0 ns;
                  counter <= ('0' & casLatency) - '1';
                  WAIT FOR 0 ns;
                  latency <= '1';
                  WAIT FOR 0 ns;
         WHEN "0110" =>
--                  display(to_string(NOW) & "ns : Burst Terminate");
                  write(lin,NOW);
                  write(lin," : Burst Terminate");
                  writeline(output,lin);

         WHEN "0111" =>
                  --$display($time,"ns : Nop Command");
                  IF ((write_state = '1') AND (counter /= "0000")) THEN
                     counter <= counter - "0001";
                     WAIT FOR 0 ns;
                     IF (counter = "0000") THEN
                        write_1 <= '0';
                        WAIT FOR 0 ns;
                     ELSE
                        column <= column + '1';
                        wait for 0 ns;
                        Memory(conv_integer(row & column & bank)) <= sdr_DQ;
                        WAIT FOR 0 ns;                       
                         write_count <= write_count +1;
--                        display(to_string(NOW) & "ns :write: Bank=" & to_decstring(bank,CALC_DECLEN(bank))
--                  			& ",Row=" & to_decstring(row,CALC_DECLEN(row))
--                  			& ",Column=" & to_decstring(column,CALC_DECLEN(column))
--                  			--& ",Data=" & to_hexstring(sdr_DQ));
--                  			& ",Data=" & to_decstring(sdr_DQ,CALC_DECLEN(sdr_DQ)));
                          write(lin,NOW);
                          write(lin," : write : Bank = 0x");
                          hwrite(lin,bank_4x);
                          write(lin,", Row = 0x");
                          hwrite(lin,row_4x);
                          write(lin,", Column = 0x");
                          hwrite(lin,column_4x);
                          write(lin,", Data = 0x");
                          hwrite(lin,sdr_DQ_4x);
                          writeline(output,lin);
                     END IF;
                  ELSE
                     IF ((read = '1') AND (counter /= "0000")) THEN
                        counter <= counter - "0001";
                        WAIT FOR 0 ns;
                        IF (counter = "0000") THEN
                           read <= '0';
                           WAIT FOR 0 ns;
                           enableSdrDQ <= '0' AFTER tOH_DLY;
                        ELSE
                           column <= column + '1';
                           wait for 0 ns;
 						               WAIT FOR tAC_DLY; 
                           dataOut <= Memory(conv_integer(row & column & bank));-- AFTER to_time(integer(tAC));
--                           display(to_string(NOW) & "ns :read: Bank=" & to_decstring(bank,CALC_DECLEN(bank))
--                  				 & ",Row=" & to_decstring(row,CALC_DECLEN(row))
--                  				 & ",Column=" & to_decstring(column,CALC_DECLEN(column))
--                  				 & ",Data=" & to_decstring(dataOut,CALC_DECLEN(dataOut)));
wait for 0 ns;
Memory_read(conv_integer(row & column & bank)) <= dataout;
wait for 0 ns;
read_count <= read_count +1;

                          write(lin,NOW);
                          write(lin," : read : Bank = 0x");
                          hwrite(lin,bank_4x);
                          write(lin,", Row = 0x");
                          hwrite(lin,row_4x);
                          write(lin,", Column = 0x");
                          hwrite(lin,column_4x);
                          write(lin,", Data = 0x");
                          hwrite(lin,dataOut_4x);--Memory(conv_integer(row & column & bank)));--
                          writeline(output,lin);
                        END IF;
                     ELSE
                        IF ((latency = '1') AND (counter /= "0000")) THEN
                           counter <= counter - "0001";
                           WAIT FOR 0 ns;                          
                           IF (counter = "0000") THEN
                              latency <= '0';
                              WAIT FOR 0 ns;
                              read <= '1';
                              WAIT FOR 0 ns;
                              counter <= "0" & burstLength;
                              WAIT FOR 0 ns;
                              wait for tAC_DLY;
                              dataOut <= Memory(conv_integer(row & column & bank));-- AFTER to_time(integer(tAC));
                              WAIT FOR 0 ns;
							  enableSdrDQ <= '1';
                              WAIT FOR 0 ns;
							  Memory_read(conv_integer(row & column & bank)) <= dataout;
							  WAIT FOR 0 ns;
							  read_count <= read_count +1;
--                              display(to_string(NOW) & "ns :read: Bank=" & to_decstring(bank,CALC_DECLEN(bank))
--                  						& ",Row=" & to_decstring(row,CALC_DECLEN(row))
--                  						& ",Column=" & to_decstring(column,CALC_DECLEN(column))
--                  						& ",Data=" & to_decstring(dataOut,CALC_DECLEN(dataOut)));
                              write(lin,NOW);
                              write(lin," : read : Bank = 0x");
                              hwrite(lin,bank_4x);
                              write(lin,", Row = 0x");
                              hwrite(lin,row_4x);
                              write(lin,", Column = 0x");
                              hwrite(lin,column_4x);
                              write(lin,", Data = 0x");
                              hwrite(lin,dataOut_4x);--Memory(conv_integer(row & column & bank)));--
                              writeline(output,lin);

                           END IF;
                        END IF;
                     END IF;
                  END IF;
         WHEN OTHERS =>
                  NULL;

      END CASE;
   END PROCESS;

   --bank <= bank_0 WHEN bank_0'ACTIVE ELSE
     --      bank_1 WHEN bank_1'ACTIVE ELSE
       --    bank;

   burstLength <= burstLength_0 WHEN burstLength_0'ACTIVE ELSE
                  burstLength_1 WHEN burstLength_1'ACTIVE ELSE
                  burstLength;

   casLatency <= casLatency_0 WHEN casLatency_0'ACTIVE ELSE
                 casLatency_1 WHEN casLatency_1'ACTIVE ELSE
                 casLatency;

   --column <= column_0 WHEN column_0'ACTIVE ELSE
     --        column_1 WHEN column_1'ACTIVE ELSE
       --      column;

   --counter <= counter_0 WHEN counter_0'ACTIVE ELSE
    --          counter_1 WHEN counter_1'ACTIVE ELSE
      --        counter;

   --dataOut <= dataOut_0 WHEN dataOut_0'ACTIVE ELSE
    --          dataOut_1 WHEN dataOut_1'ACTIVE ELSE
     --         dataOut;

   --enableSdrDQ <= enableSdrDQ_0 WHEN enableSdrDQ_0'ACTIVE ELSE
   --               enableSdrDQ_1 WHEN enableSdrDQ_1'ACTIVE ELSE
   --               enableSdrDQ;

   --latency <= latency_0 WHEN latency_0'ACTIVE ELSE
     --         latency_1 WHEN latency_1'ACTIVE ELSE
       --       latency;

   --read <= read_0 WHEN read_0'ACTIVE ELSE
   --        read_1 WHEN read_1'ACTIVE ELSE
    --       read;

   row <= row_0 WHEN row_0'ACTIVE ELSE
          row_1 WHEN row_1'ACTIVE ELSE
          row;

   write_state <= write_0 WHEN write_0'ACTIVE ELSE
            write_1 WHEN write_1'ACTIVE ELSE
            write_state;
			
			
process (sdr_CK)
variable i : integer;
variable flag : std_logic;
VARIABLE li          : LINE;
begin
flag:='1';
if (read_count = write_count) and (write_count /= 0) then
	for i in 0 to (read_count-1) loop
		if (Memory(i) = Memory_read(i)) then
			flag:= ('1' and flag);
		else
			flag:=('0' and flag);
		end if;
--wait for 0 ns;
	end loop;
	

    write(li," ---------------------------------------------------------------------------------------------------------- ");
 	writeline(output,li);
	write(li," ---------------------------------------------------------------------------------------------------------- ");
 	writeline(output,li);
	
	
	if (flag = '1') then
	write(li," --------------------------------------------------TEST PASS----------------------------------------------- ");
 	writeline(output,li);
	else
	write(li," --------------------------------------------------TEST FAIL----------------------------------------------- ");
 	writeline(output,li);
	end if;
	
	
	
	write(li," ---------------------------------------------------------------------------------------------------------- ");
 	writeline(output,li);
	write(li," ---------------------------------------------------------------------------------------------------------- ");
 	writeline(output,li);
	
	stop(0);		
		
	end if;
end process;

END ARCHITECTURE translated;

--use work.system.all;
LIBRARY ieee,STD,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.sdr_par.all;
use std.textio.all;
--
ENTITY system IS
   PORT (
      -----------------------------------------------------------------------
-- outputs & registers
--
      sys_CLK                 : OUT std_logic;
      sys_RESET               : OUT std_logic;
      sys_A                   : OUT std_logic_vector(23 DOWNTO 1);
      sys_ADSn                : OUT std_logic;
      sys_R_Wn                : OUT std_logic;
      sys_D                   : OUT std_logic_vector(15 DOWNTO 0);
      sys_DLY_100US           : OUT std_logic;
      sys_REF_REQ             : OUT std_logic;
      sys_CYC_END             : IN std_logic;
      sys_INIT_DONE           : IN std_logic);
END ENTITY system;

ARCHITECTURE translated OF system IS

   CONSTANT hdl_timescale         : time := 1 ns;
   --TYPE hdl_1 IS ARRAY (0 TO MEM_SIZE - 1) OF std_logic_vector(Data_Width - 1 DOWNTO 0);

   SIGNAL sys_CLK_int              :  std_logic;
   SIGNAL sys_CLK_int_0            :  std_logic;
   SIGNAL sys_CLK_int_1            :  std_logic;
   SIGNAL sys_CLK_en               :  std_logic;
   -----------------------------------------------------------------------
   -- parameters -- change to whatever you like
   --
   CONSTANT  clock_time            :  time := 100 ns;
   CONSTANT  reset_time            :  time := 1000 ns;
   CONSTANT  sys_CLK_period        :  time := tCK;
   SIGNAL sys_CLK_hdl1            :  std_logic;
   SIGNAL sys_RESET_hdl2          :  std_logic;
   SIGNAL sys_A_hdl3              :  std_logic_vector(23 DOWNTO 1);
   SIGNAL sys_ADSn_hdl4           :  std_logic;
   SIGNAL sys_R_Wn_hdl5           :  std_logic;
   SIGNAL sys_D_hdl6              :  std_logic_vector(15 DOWNTO 0);
   SIGNAL sys_DLY_100US_hdl7      :  std_logic;
   SIGNAL sys_REF_REQ_hdl8        :  std_logic;
   SIGNAL tCK                      :  std_logic;

BEGIN
   sys_CLK <= sys_CLK_hdl1;
   sys_RESET <= sys_RESET_hdl2;
   sys_A <= sys_A_hdl3;
   sys_ADSn <= sys_ADSn_hdl4;
   sys_R_Wn <= sys_R_Wn_hdl5;
   sys_D <= sys_D_hdl6;
   sys_DLY_100US <= sys_DLY_100US_hdl7;
   sys_REF_REQ <= sys_REF_REQ_hdl8;

   -----------------------------------------------------------------------
   -- code
   --
   PROCESS
      VARIABLE hdl_initial : BOOLEAN := TRUE;
      VARIABLE lin            : LINE;
      PROCEDURE read0 (
      addr                    : IN std_logic_vector(23 DOWNTO 1);
      signal sys_A_hdl3		  : OUT std_logic_vector(23 DOWNTO 1);
      signal sys_ADSn_hdl4   : OUT std_logic;
      signal sys_R_Wn_hdl5   : OUT std_logic
      )IS
      BEGIN
         sys_A_hdl3 <= addr;
         --WAIT FOR 0 ns;
         sys_ADSn_hdl4 <= '0';
         --WAIT FOR 0 ns;
         sys_R_Wn_hdl5 <= '1';
         --WAIT FOR 0 ns;
         WAIT FOR sys_CLK_period;
         sys_ADSn_hdl4 <= '1';
         --WAIT FOR 0 ns;
         --WAIT HASH(0x1f2a4dc);
         WAIT FOR (sys_CLK_period * ( NUM_CLK_CL + NUM_CLK_READ + 3));

         sys_R_Wn_hdl5 <= '1';
         --WAIT FOR 0 ns;
         sys_A_hdl3 <= "ZZZZZZZZZZZZZZZZZZZZZZZ";
         --WAIT FOR 0 ns;
      END PROCEDURE read0;

      -----------------------------------------------------------------------
      -- tasks
      --
      PROCEDURE write0 (
         addr                    : IN std_logic_vector(23 DOWNTO 1);
         data                    : IN std_logic_vector(15 DOWNTO 0);
         signal sys_A_hdl3		   : OUT std_logic_vector(23 DOWNTO 1);
         signal sys_ADSn_hdl4   : OUT std_logic;
         signal sys_R_Wn_hdl5   : OUT std_logic 
         )IS
      BEGIN
         sys_A_hdl3 <= addr;
         --WAIT FOR 0 ns;
         sys_ADSn_hdl4 <= '0';
         --WAIT FOR 0 ns;
         sys_R_Wn_hdl5 <= '0';
         --WAIT FOR 0 ns;
         WAIT FOR sys_CLK_period;

         sys_ADSn_hdl4 <= '1';
         --WAIT FOR 0 ns;
         sys_D_hdl6 <= data;
         --WAIT FOR 0 ns;
         WAIT FOR sys_CLK_period * ( NUM_CLK_WRITE + NUM_CLK_WAIT + 4);

         sys_D_hdl6 <= "ZZZZZZZZZZZZZZZZ";
         --WAIT FOR 0 ns;
         sys_R_Wn_hdl5 <= '1';
         --WAIT FOR 0 ns;
         sys_A_hdl3 <= "ZZZZZZZZZZZZZZZZZZZZZZZ";
         --WAIT FOR 0 ns;
      END PROCEDURE write0;
      --
   BEGIN
      IF (hdl_initial) THEN
         sys_R_Wn_hdl5 <= '1' AFTER 1 * hdl_timescale;
         sys_ADSn_hdl4 <= '1' AFTER 1 * hdl_timescale;
         sys_DLY_100US_hdl7 <= '0' AFTER 1 * hdl_timescale;
         sys_REF_REQ_hdl8 <= '0' AFTER 1 * hdl_timescale;
         sys_CLK_int_0 <= '0' AFTER 1 * hdl_timescale;
         sys_RESET_hdl2 <= '1' AFTER 1 * hdl_timescale;
         sys_A_hdl3 <= "11111111111111111111111" AFTER 1 * hdl_timescale;
         sys_D_hdl6 <= "ZZZZZZZZZZZZZZZZ" AFTER 1 * hdl_timescale;
         sys_CLK_en <= '0' AFTER 1 * hdl_timescale;
         WAIT FOR clock_time;

         sys_CLK_en <= '1' AFTER 1 * hdl_timescale;
         WAIT FOR reset_time;

         WAIT UNTIL (sys_CLK_hdl1'EVENT AND sys_CLK_hdl1 = '1');

--         display(to_string(NOW) & "ns  : Coming Out Of Reset");
         write(lin,NOW);
         write(lin,"    : Coming Out Of Reset.");
         writeline(output,lin);
         sys_RESET_hdl2 <= '0' AFTER 1 * hdl_timescale;
         WAIT FOR 100001 * hdl_timescale;

         sys_DLY_100US_hdl7 <= '1' AFTER 1 * hdl_timescale;
         WAIT UNTIL (sys_INIT_DONE'EVENT AND sys_INIT_DONE = '1');

         WAIT FOR 500 * hdl_timescale;

         WAIT UNTIL (sys_CLK_hdl1'EVENT AND sys_CLK_hdl1 = '0');

         write0("00000000000000000000000", "0001001000110100",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         write0("00000000000001000000000", "0101011001111000",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         write0("00000000000010000000000", "1001101010111100",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         write0("00000000000011000000000", "1101111011110000",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         read0("00000000000000000000000",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         read0("00000000000001000000000",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         read0("00000000000010000000000",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         read0("00000000000011000000000",sys_A_hdl3,sys_ADSn_hdl4,sys_R_Wn_hdl5);
         --ASSERT (False) REPORT "'$Stop' Encountered" SEVERITY Failure;
--         display(to_string(now)& "ns '$Stop' Encountered");
         write(lin,NOW);
         write(lin," : End of simulation.");
         writeline(output,lin);
         hdl_initial := FALSE;
      ELSE
         WAIT;
      END IF;
   END PROCESS;

   PROCESS
   BEGIN
      --WAIT HASH(0x1f266fc);
      WAIT FOR 10 ns;
      sys_CLK_int_1 <= NOT sys_CLK_int;
   END PROCESS;
   sys_CLK_hdl1 <= sys_CLK_en AND sys_CLK_int ;

   sys_CLK_int <= sys_CLK_int_0 WHEN sys_CLK_int_0'ACTIVE ELSE
                  sys_CLK_int_1 WHEN sys_CLK_int_1'ACTIVE ELSE
                  sys_CLK_int;

END ARCHITECTURE translated;
---
LIBRARY ieee,STD,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.sdr_par.all;

ENTITY sdr_tb IS
END ENTITY sdr_tb;

ARCHITECTURE translated OF sdr_tb IS

   SIGNAL sys_R_Wn                 :  std_logic;   --  read/write#
   SIGNAL sys_ADSn                 :  std_logic;   --  address strobe
   SIGNAL sys_DLY_100US            :  std_logic;   --  sdr power and clock stable for 100 us
   SIGNAL sys_CLK                  :  std_logic;   --  sdr clock
   SIGNAL sys_RESET                :  std_logic;   --  reset signal
   SIGNAL sys_REF_REQ              :  std_logic;   --  sdr auto-refresh request
   SIGNAL sys_REF_ACK              :  std_logic;   --  sdr auto-refresh acknowledge
   SIGNAL sys_A                    :  std_logic_vector(23 DOWNTO 1);   --  address bus
   SIGNAL sys_D                    :  std_logic_vector(15 DOWNTO 0);   --  data bus
   SIGNAL sys_D_VALID              :  std_logic;   --  data valid
   SIGNAL sys_CYC_END              :  std_logic;   --  end of current cycle
   SIGNAL sys_INIT_DONE            :  std_logic;   --  initialization completed, ready for normal operation
   SIGNAL sdr_DQ                   :  std_logic_vector(3 DOWNTO 0);   --  sdr data
   SIGNAL sdr_A                    :  std_logic_vector(11 DOWNTO 0);   --  sdr address
   SIGNAL sdr_BA                   :  std_logic_vector(1 DOWNTO 0);   --  sdr bank address
   SIGNAL sdr_CKE                  :  std_logic;   --  sdr clock enable
   SIGNAL sdr_CSn                  :  std_logic;   --  sdr chip select
   SIGNAL sdr_RASn                 :  std_logic;   --  sdr row address
   SIGNAL sdr_CASn                 :  std_logic;   --  sdr column select
   SIGNAL sdr_WEn                  :  std_logic;   --  sdr write enable
   SIGNAL sdr_DQM                  :  std_logic;   --  sdr write data mask

-- Instantiate the sdr_top module
COMPONENT sdr_top
		Port(
				sys_R_Wn			: IN std_logic;
				sys_ADSn			: IN std_logic;
				sys_DLY_100US	: IN std_logic;
				sys_CLK				: IN std_logic;
				sys_RESET			: IN std_logic;
				sys_REF_REQ		: IN std_logic;
				sys_REF_ACK		: OUT std_logic;
				sys_A					: IN std_logic_vector(RA_MSB DOWNTO CA_LSB);
				sys_D					: INOUT std_logic_vector(15 DOWNTO 0);
				sys_D_VALID		: OUT std_logic;
				sys_CYC_END		: OUT std_logic;
				sys_INIT_DONE	:	OUT std_logic;
				sdr_DQ				: INOUT std_logic_vector(3 DOWNTO 0);
				sdr_A					: OUT std_logic_vector(SDR_A_WIDTH -1 DOWNTO 0);
				sdr_BA				: OUT std_logic_vector(SDR_BA_WIDTH -1 DOWNTO 0);
				sdr_CKE				: OUT std_logic;
				sdr_CSn				: OUT std_logic;
				sdr_RASn			: OUT std_logic;
				sdr_CASn			: OUT std_logic;
				sdr_WEn				: OUT std_logic;
				sdr_DQM 			: OUT std_logic
				);
end COMPONENT;
-- Instantiate the system module
COMPONENT system
		 PORT (
      -----------------------------------------------------------------------
-- outputs & registers
--
      sys_CLK                 : OUT std_logic;
      sys_RESET               : OUT std_logic;
      sys_A                   : OUT std_logic_vector(23 DOWNTO 1);
      sys_ADSn                : OUT std_logic;
      sys_R_Wn                : OUT std_logic;
      sys_D                   : OUT std_logic_vector(15 DOWNTO 0);
      sys_DLY_100US           : OUT std_logic;
      sys_REF_REQ             : OUT std_logic;
      sys_CYC_END             : IN std_logic;
      sys_INIT_DONE           : IN std_logic
      );
END COMPONENT;
--Instantiate the sdr module
COMPONENT sdr
			PORT
			(
      sdr_DQ                  : INOUT std_logic_vector(3 DOWNTO 0);
      -----------------------------------------------------------------------
-- ports
--
      sdr_A                   : IN std_logic_vector(SDR_A_WIDTH - 1 DOWNTO 0);
      sdr_BA                  : IN std_logic_vector(SDR_BA_WIDTH - 1 DOWNTO 0);
      sdr_CK                  : IN std_logic;
      sdr_CKE                 : IN std_logic;
      sdr_CSn                 : IN std_logic;
      sdr_RASn                : IN std_logic;
      sdr_CASn                : IN std_logic;
      sdr_WEn                 : IN std_logic;
      sdr_DQM                 : IN std_logic
      );
END COMPONENT;
--begin the main process
BEGIN
   -----------------------------------------------------------------------
   -- modules
   -- read/write#
   -- address strobe
   -- sdr power and clock stable for 100 us
   -- sdr clock
   -- reset signal
   -- sdr auto-refresh request
   -- sdr auto-refresh acknowledge
   -- address bus
   -- data bus
   -- data valid
   -- end of current cycle
   -- initialization completed, ready for normal operation
   -- sdr data
   -- sdr address
   -- sdr bank address
   -- sdr clock enable
   -- sdr chip select
   -- sdr row address
   -- sdr column select
   -- sdr write enable
   -- sdr write data mask
   UUT : sdr_top
   PORT MAP (
         sys_R_Wn => sys_R_Wn,
         sys_ADSn => sys_ADSn,
         sys_DLY_100US => sys_DLY_100US,
         sys_CLK => sys_CLK,
         sys_RESET => sys_RESET,
         sys_REF_REQ => sys_REF_REQ,
         sys_REF_ACK => sys_REF_ACK,
         sys_A => sys_A,
         sys_D => sys_D,
         sys_D_VALID => sys_D_VALID,
         sys_CYC_END => sys_CYC_END,
         sys_INIT_DONE => sys_INIT_DONE,
         sdr_DQ => sdr_DQ,
         sdr_A => sdr_A,
         sdr_BA => sdr_BA,
         sdr_CKE => sdr_CKE,
         sdr_CSn => sdr_CSn,
         sdr_RASn => sdr_RASn,
         sdr_CASn => sdr_CASn,
         sdr_WEn => sdr_WEn,
         sdr_DQM => sdr_DQM
         );

   STIMULUS : system
   PORT MAP (
         sys_CLK => sys_CLK,
         sys_RESET => sys_RESET,
         sys_A => sys_A,
         sys_ADSn => sys_ADSn,
         sys_R_Wn => sys_R_Wn,
         sys_D => sys_D,
         sys_DLY_100US => sys_DLY_100US,
         sys_REF_REQ => sys_REF_REQ,
         sys_CYC_END => sys_CYC_END,
         sys_INIT_DONE => sys_INIT_DONE
         );

   -- Module "mt48lc32m4a2" can be downloaded from Micro's web site.
   --mt48lc32m4a2 SDR_SDRAM(
   
   SDR_SDRAM : sdr
   PORT MAP (
         sdr_DQ,
         sdr_A,
         sdr_BA,
         sys_CLK,
         sdr_CKE,
         sdr_CSn,
         sdr_RASn,
         sdr_CASn,
         sdr_WEn,
         sdr_DQM
         );

END ARCHITECTURE translated;
